import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class ISnackBarService {
  showError(BuildContext context, String msg);
}

class SnackBarService implements ISnackBarService {
  @override
  showError(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}