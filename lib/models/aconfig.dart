import 'package:configapplier/models/pconfig.dart';

class AConfig {
  Map<String, dynamic> aConfig;

  AConfig({required this.aConfig});

  PConfig apply(PConfig pConfig) {
    final pConfigClone = pConfig.clone();
    aConfig.forEach((key, value) {
      final path = key.split('/');
      pConfigClone.setValue(path, value, null);
    });
    return pConfigClone;
  }
}