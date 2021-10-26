class PConfig {
  Map<String, dynamic> pConfig;
  String version;
  String filepath;

  PConfig({required this.pConfig, required this.version, required this.filepath});

  PConfig clone() {
    return PConfig(
      pConfig: Map.from(pConfig),
      version: String.fromCharCodes(version.codeUnits),
      filepath: String.fromCharCodes(filepath.codeUnits),
    );
  }

  getValue(List<String> path, Map<String, dynamic>? currentMap) {
    if (path.length == 1) {
      return currentMap == null ? pConfig[path.first] : currentMap[path.first];
    }
    final str = path.first;
    path.removeAt(0);
    return getValue(path, currentMap == null ? pConfig[str] : currentMap[str]);
  }

  void setValue(List<String> path, value, Map<String, dynamic>? currentMap) {
    if (path.length == 1) {
      pConfig[path.first] = value;
    } else {
      currentMap ??= getValue(List.from(path)..removeLast(), null);
      currentMap![path.last] = value;
      path.removeLast();
      setValue(path, currentMap, getValue(path, null));
    }
  }

  String compose() {
    final str = "\<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "\<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
        "\<plist version=\"$version\">\n" + _compose(pConfig, 0) + "\</plist>";
    return str;
  }

  String _compose(Map<String, dynamic> map, int indent) {
    switch (map["type"]) {
      case "dict":
        final keys = map["content"].keys.toList();
        if (keys.length == 0) return "\t" * indent + "\<dict/>\n";
        String str = "\t" * indent + "\<dict>\n";
        for (final k in keys) {
          str += "\t" * (indent+1) + _getEntryStr("key", k) + "\n" + _compose(map["content"][k], indent+1);
        }
        return str + "\t" * indent + "\</dict>\n";
      case "array":
        if (map["content"].length == 0) return "\t" * indent + "\<array/>\n";
        String str = "\t" * indent + "\<array>\n";
        for (final e in map["content"]) {
          str += _compose(e, indent+1);
        }
        return str + "\t" * indent + "\</array>\n";
      default:
        return "\t" * indent + _getEntryStr(map["type"], map["content"]) + "\n";
    }
  }

  String _getEntryStr(String type, String content) {
    switch(type) {
      case "bool": return "\<${content == "1" ? "true" : "false"}/>";
      default: return "\<$type>$content\</$type>";
    }
  }
}