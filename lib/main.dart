import 'package:flutter/material.dart';

import 'composition_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CompositionRoot.init();
  final firstPage = CompositionRoot.start();
  runApp(Main(firstPage: firstPage));
}

class Main extends StatelessWidget {
  final Widget firstPage;

  const Main({required this.firstPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConfigApplier',
      home: firstPage,
    );
  }
}
