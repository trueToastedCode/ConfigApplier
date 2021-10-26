import 'package:configapplier/models/aconfig.dart';
import 'package:configapplier/models/pconfig.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  final PConfig? pConfig;
  final AConfig? aConfig;

  const HomeState(this.pConfig, this.aConfig);

  _props() {
    List<Object> objects = [];
    if (pConfig != null) {
      objects.add(pConfig!);
    }
    if (aConfig != null) {
      objects.add(aConfig!);
    }
    return objects;
  }

  @override
  List<Object> get props => _props();
}

class HomeInputState extends HomeState {
  const HomeInputState({
    PConfig? pConfig,
    AConfig? aConfig
  }) : super(pConfig, aConfig);
}

class HomeInputLoadingState extends HomeState {
  const HomeInputLoadingState({
    PConfig? pConfig,
    AConfig? aConfig
  }) : super(pConfig, aConfig);
}

class HomeInputLoadingFailureState extends HomeState {
  final String msg;

  const HomeInputLoadingFailureState({
    PConfig? pConfig,
    AConfig? aConfig,
    required this.msg
  }) : super(pConfig, aConfig);

  @override
  List<Object> get props => _props()..add(msg);
}