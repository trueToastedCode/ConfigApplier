import 'dart:convert';
import 'dart:io';

import 'package:configapplier/models/aconfig.dart';
import 'package:configapplier/models/pconfig.dart';
import 'package:configapplier/services/aconfig_service.dart';
import 'package:configapplier/services/pconfig_service.dart';
import 'package:configapplier/states_management/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final IPConfigService pConfigService;
  final IAConfigService aConfigService;

  HomeCubit({
    required this.pConfigService,
    required this.aConfigService
  }) : super(const HomeInputState());

  readSample(HomeState state, String path) {
    emit(HomeInputLoadingState(pConfig: state.pConfig, aConfig: state.aConfig));
    PConfig pConfig;
    try {
      pConfig = pConfigService.read(path);
    } catch(e) {
      emit(HomeInputLoadingFailureState(
        aConfig: state.aConfig,
        msg: 'Unable to read sample'),
      );
      return;
    }
    // try {
    //   final nPath = '${path.substring(0, path.length-path.split('.').toList().last.length)}json';
    //   JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    //   final data = encoder.convert(pConfig.pConfig);
    //   File(nPath).writeAsStringSync(data);
    // } catch(e) {
    //   emit(HomeInputLoadingFailureState(
    //     pConfig: state.pConfig,
    //     aConfig: state.aConfig,
    //     msg: 'Unable to write sample as json'),
    //   );
    //   return;
    // }
    emit(HomeInputState(aConfig: state.aConfig, pConfig: pConfig));
  }

  readConfig(HomeState state, String path) {
    emit(HomeInputLoadingState(pConfig: state.pConfig, aConfig: state.aConfig));
    AConfig aConfig;
    try {
      aConfig = aConfigService.read(path);
    } catch(e) {
      emit(HomeInputLoadingFailureState(
        pConfig: state.pConfig,
        msg: 'Unable to read config'),
      );
      return;
    }
    emit(HomeInputState(aConfig: aConfig, pConfig: state.pConfig));
  }
}