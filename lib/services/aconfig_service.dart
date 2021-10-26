import 'dart:convert';
import 'dart:io';

import 'package:configapplier/models/aconfig.dart';

abstract class IAConfigService {
  AConfig read(String path);
}

class AConfigService implements IAConfigService {
  @override
  AConfig read(String path) {
    String data = File(path).readAsStringSync();
    final aConfigMap = jsonDecode(data);
    final aConfig = AConfig(aConfig: aConfigMap);
    return aConfig;
  }
}