import 'package:flutter/cupertino.dart';

abstract class IFileOpenWidget extends StatefulWidget {
  const IFileOpenWidget({Key? key}) : super(key: key);

  openFiles(List<String> paths);
}