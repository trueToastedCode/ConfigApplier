import 'package:configapplier/services/aconfig_service.dart';
import 'package:configapplier/services/pconfig_service.dart';
import 'package:configapplier/services/snackbar_service.dart';
import 'package:configapplier/states_management/home/home_cubit.dart';
import 'package:configapplier/ui/pages/home/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompositionRoot {
  static late final ISnackBarService _snackBarService;
  static late final IPConfigService _pConfigService;
  static late final IAConfigService _aConfigService;

  static init() async {
    _snackBarService = SnackBarService();
    _pConfigService = PConfigService();
    _aConfigService = AConfigService();
  }

  static Widget start() {
    return composeHomeUi();
  }

  static Widget composeHomeUi() {
    final homeCubit = HomeCubit(
        pConfigService: _pConfigService, aConfigService: _aConfigService);
    return BlocProvider(
      create: (BuildContext context) => homeCubit,
      child: HomePage(
        snackBarService: _snackBarService,
        pConfigService: _pConfigService,
      ),
    );
  }
}