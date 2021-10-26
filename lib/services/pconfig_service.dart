import 'dart:convert';
import 'dart:io';

import 'package:configapplier/models/pconfig.dart';

abstract class IPConfigService {
  PConfig read(String path);
  void write(PConfig pConfig, String path);
  void writeJson(PConfig pConfig, String path);
}

class PConfigService implements IPConfigService {
  @override
  PConfig read(String path) {
    // read into string
    String data = File(path).readAsStringSync();
    // remove lines and spaces
    data = data.split("\n").map((String line) {
      for (int i=0; i<line.length; i++) {
        if (line[i] != " " && line[i] != "\t") {
          return line.substring(i);
        }
      }
      return "";
    }).toList().join();
    // find plist, parse meta
    List<dynamic> res;
    String version;
    while (true) {
      res = _parsePrefix(data);
      data = res[2];
      if (res[0] != null) {
        if (res[0] == "plist") {
          try {
            version = res[1]["version"];
          }catch (e) {
            version = "1.0";
          }
          break;
        }
      }
      if (data.isEmpty) {
        throw Exception("Error parsing file (No content left to find plist)");
      }
    }
    // parse plist
    final pConfigMap = _parse("plist", data)[0][0];
    final pConfig = PConfig(pConfig: pConfigMap, version: version, filepath: path);
    return pConfig;
  }

  @override
  void write(PConfig pConfig, String path) {
    final data = pConfig.compose();
    File(path).writeAsStringSync(data);
  }

  List<dynamic> _parse(String key, String str) {
    List<dynamic> list = [];
    while (true) {
      if (str.substring(0, key.length + 3) == "\</$key>") {
        if (key == "dict") {
          if (list.isEmpty) list.add({});
          return list..add(str.substring(key.length + 3));
        }
        return [list, str.substring(key.length + 3)];
      }
      // next suffix (no comment or meta)
      List<dynamic>? res = _nextPrefix(str);
      if (res == null) throw Exception("Suffix not found!");
      str = res[2];
      // analyse type, then add or return
      switch (res[0]) {
        case "dict":
          final res = _parse("dict", str);
          final entry = _getEntryDic("dict", res[0]);
          if (key == "key") return [entry, res[1]];
          list.add(entry);
          str = res[1];
          break;
        case "dict/":
          final entry = _getEntryDic("dict", {});
          if (key == "key") return [entry, str];
          list.add(entry);
          break;
        case "array":
          final res = _parse("array", str);
          final entry = _getEntryDic("array", res[0]);
          if (key == "key") return [entry, res[1]];
          list.add(entry);
          str = res[1];
          break;
        case "array/":
          final entry = _getEntryDic("array", []);
          if (key == "key") return [entry, str];
          list.add(entry);
          break;
        case "bool":
          final entry = _getEntryDic(res[0], res[1]["value"]);
          if (key == "key") return [entry, str];
          list.add(entry);
          break;
        default:
          if (res[0][res[0].length-1] == "/") {
            final type = res[0].substring(0, res[0].length-1);
            if (type == "key") {
              throw Exception("Key has no name");
            } else if (key == "key") {
              return [_getEntryDic(type, ""), str];
            }
            list.add(_getEntryDic(type, ""));
          } else {
            final index = str.indexOf("\</${res[0]}>");
            if (index == -1) {
              throw Exception("Error finding end: \"${res[0]}\"");
            }
            final value = str.substring(0, index);
            str = str.substring(index+"\</${res[0]}>".length);
            if (key == "key") {
              return [_getEntryDic(res[0], value), str];
            }
            if (res[0] == "key") {
              if (key != "dict") {
                throw Exception("Key in no dic");
              } else if (str.isEmpty) {
                throw Exception("Content is missing");
              }
              final res = _parse("key", str);
              if (list.isEmpty) {
                list.add({value: res[0]});
              } else {
                list[0][value] = res[0];
              }
              str = res[1];
            } else {
              list.add(_getEntryDic(res[0], value));
            }
          }
      }
      if (str.isEmpty) {
        if (key == "dict") {
          if (list.isEmpty) {
            list.add({});
          }
          return list..add("");
        }
        return [list, ""];
      }
    }
  }

  Map<String, dynamic> _getEntryDic(String key, dynamic value) {
    return {"type": key, "content": value};
  }

  /// find next suffix (no comment or meta)
  List<dynamic>? _nextPrefix(String str) {
    List<dynamic> res;
    while (true) {
      res = _parsePrefix(str);
      if (res[0] != null) {
        return res;
      }
      str = res[2];
      if (str.isEmpty) {
        return null;
      }
    }
  }

  /// split into type, attributes, following
  List<dynamic> _parsePrefix(String str) {
    if (str[0] != "<") {
      throw Exception("Invalid suffix: ${str.length > 10 ? str.substring(0, 10) + "..." : str}");
    }
    switch (str[1]) {
      case "!":
        return [null, null, _parsePrefixHelper(str.substring(2), ">", false)[2]];
      case "?":
        final res = _parsePrefixHelper(str.substring(2), "?>", true);
        return [null, res[1], res[2]];
      default:
        final res = _parsePrefixHelper(str.substring(1), ">", true);
        if (res[0][res[0].length-1] == "/") {
          switch (res[0]) {
            case "true/":
              return ["bool", {"value": "1"}, res[2]];
            case "false/":
              return ["bool", {"value": "0"}, res[2]];
            default:
              return res;
          }
        } else {
          return res;
        }
    }
  }

  /// split into type, attributes, following
  List<dynamic> _parsePrefixHelper(String str, String end, bool parseAttrs) {
    String? typeStr, attrsStr, followingStr;
    int x = 0;
    for (int i=0; i<=str.length-end.length; i++) {
      if (typeStr != null) {
        if (str.substring(i, i+end.length) == end) {
          // end after args
          if (parseAttrs) attrsStr = str.substring(x, i);
          followingStr = str.substring(i+end.length);
          break;
        }
      } else if (str[i] == " ") {
        // end with args starting
        typeStr = str.substring(0, i);
        if (parseAttrs) x = i;
      } else if (str.substring(i, i+end.length) == end) {
        // end without args
        typeStr = str.substring(0, i);
        followingStr = str.substring(i+end.length);
        break;
      }
    }
    if (typeStr == null || followingStr == null) {
      throw Exception("Invalid suffix: ${str.length > 10 ? str.substring(0, 10) + "..." : str}");
    }
    if (!parseAttrs || attrsStr == null) {
      return [typeStr, {}, followingStr];
    }
    return [typeStr, _parseAttrs(attrsStr), followingStr];
  }

  /// map valid attributes
  Map<String, String> _parseAttrs(String str) {
    Map<String, String> attrs = {};
    if (str.length < 3) return attrs;
    //region parse into parts
    bool cap = false, ignore = false;
    String? part;
    List<String> parts = [];
    for (int i=0; i<str.length; i++) {
      if (cap) {
        if (ignore) {
          if (part == null) {
            throw Exception('Unexpected null');
          }
          part += str[i];
          if (str[i] == "\"") ignore = false;
        }else if (str[i] == " ") {
          if (part == null) {
            throw Exception('Unexpected null');
          }
          parts.add(part);
          part = null;
          cap = false;
        }else if (str[i] == "\"") {
          if (part == null) {
            throw Exception('Unexpected null');
          }
          part += str[i];
          ignore = true;
        }else {
          if (part == null) {
            throw Exception('Unexpected null');
          }
          part += str[i];
        }
      }else if (str[i] != " ") {
        part = str[i];
        cap = true;
      }
    }
    if (part != null) {
      parts.add(part);
    }
    //endregion
    if (parts.isEmpty) {
      return attrs;
    }
    //region parse parts into map
    for (final part in parts) {
      List<String>? partParts;
      for (int i=0; i<part.length; i++) {
        if (part[i] == "=" && i != 0) {
          partParts = [part.substring(0, i), part.substring(i+1, part.length)];
          break;
        }
      }
      if (partParts == null || partParts[1].isEmpty) {
        continue;
      }
      if (partParts[1][0] == "\"" && partParts[1][partParts[1].length-1] == "\"") {
        attrs[partParts[0]] = partParts[1].substring(1, partParts[1].length-1);
      } else {
        attrs[partParts[0]] = partParts[1];
      }
    }
    //endregion
    return attrs;
  }

  @override
  void writeJson(PConfig pConfig, String path) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    final data = encoder.convert(pConfig.pConfig);
    File(path).writeAsStringSync(data);
  }
}