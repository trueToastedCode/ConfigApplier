import 'package:configapplier/services/pconfig_service.dart';
import 'package:configapplier/services/snackbar_service.dart';
import 'package:configapplier/states_management/home/home_cubit.dart';
import 'package:configapplier/states_management/home/home_state.dart';
import 'package:configapplier/ui/widgets/home/fileopen/desktop_fileopen_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  final ISnackBarService snackBarService;
  final IPConfigService pConfigService;

  const HomePage({required this.snackBarService, required this.pConfigService});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<HomeCubit, HomeState>(
          builder: (_, state) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DesktopFileOpenWidget(
                          extensions: const ['plist'],
                          maxFiles: 1,
                          enable: state is HomeInputState,
                          msg: 'Drop plist here',
                          onOpenFiles: (paths) {
                            context.read<HomeCubit>()
                                .readSample(state, paths.first);
                          },
                          onInvalidFiles: () {
                            context.read<HomeCubit>().emit(HomeInputState(aConfig: state.aConfig));
                          },
                        ),
                        Icon(
                          Icons.done,
                          size: 20.0,
                          color: state.pConfig == null ? Colors.red : Colors.green,
                        ),
                        Opacity(
                          opacity: state.pConfig == null ? 0.7 : 1.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: SizedBox(
                              height: 22.0,
                              width: 100.0,
                              child: Material(
                                color: Colors.lightBlueAccent,
                                child: InkWell(
                                  onTap: state.pConfig == null ? null : () => _saveSampleJSON(state),
                                  child: const Center(
                                    child: Text('Save as JSON', style: TextStyle(fontSize: 12.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DesktopFileOpenWidget(
                          extensions: const ['json'],
                          maxFiles: 1,
                          enable: state is HomeInputState,
                          msg: 'Drop config here',
                          onOpenFiles: (paths) {
                            context.read<HomeCubit>()
                                .readConfig(state, paths.first);
                          },
                          onInvalidFiles: () {
                            context.read<HomeCubit>().emit(HomeInputState(pConfig: state.pConfig));
                          },
                        ),
                        Icon(
                          Icons.done,
                          size: 20.0,
                          color: state.aConfig == null ? Colors.red : Colors.green,
                        ),
                        Opacity(
                          opacity: (state.pConfig == null || state.aConfig == null) ? 0.7 : 1.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: SizedBox(
                              height: 22.0,
                              width: 100.0,
                              child: Material(
                                color: Colors.lightBlueAccent,
                                child: InkWell(
                                  onTap: state.pConfig == null ? null : () => _saveNewPLIST(state),
                                  child: const Center(
                                    child: Text('Apply and Save', style: TextStyle(fontSize: 12.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          listener: (_, state) {
            if (state is HomeInputLoadingFailureState) {
              widget.snackBarService.showError(context, state.msg);
              context.read<HomeCubit>()
                  .emit(HomeInputState(
                    pConfig: state.pConfig,
                    aConfig: state.aConfig));
            }
          },
        ),
      ),
    );
  }

  _saveSampleJSON(HomeState state) {
    try {
      final path = state.pConfig!.filepath;
      final nPath = '${path.substring(0, path.length-path.split('.').toList().last.length)}json';
      widget.pConfigService.writeJson(state.pConfig!, nPath);
    } catch(e) {
      widget.snackBarService.showError(context, 'Unable to write JSON');
    }
  }

  _saveNewPLIST(HomeState state) {
    try {
      final pConfig = state.aConfig!.apply(state.pConfig!);
      final path = state.pConfig!.filepath;
      final nPath = '${path.substring(0, path.length-path.split('.').toList().last.length-1)}Applied.plist';
      widget.pConfigService.write(pConfig, nPath);
    } catch(e) {
      widget.snackBarService.showError(context, 'Unable to apply or write config');
    }
  }
}
