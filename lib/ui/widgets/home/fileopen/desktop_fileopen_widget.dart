import 'package:configapplier/ui/widgets/home/fileopen/fileopen_widget.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DesktopFileOpenWidget extends StatefulWidget implements IFileOpenWidget {
  final List<String> extensions;
  final int maxFiles;
  final bool enable;
  final Function onOpenFiles;
  final Function onInvalidFiles;
  final String msg;

  const DesktopFileOpenWidget({
    required this.extensions,
    required this.maxFiles,
    required this.enable,
    required this.onOpenFiles,
    required this.onInvalidFiles,
    required this.msg
  });

  @override
  _DesktopFileOpenWidgetState createState() => _DesktopFileOpenWidgetState();

  @override
  openFiles(List<String> paths) {
    onOpenFiles(paths);
  }
}

class _DesktopFileOpenWidgetState extends State<DesktopFileOpenWidget> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: SizedBox(
            width: 150.0,
            height: 150.0,
            child: Stack(
              children: [
                Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: const Color(0xffbdc3c7),
                  child: DropTarget(
                    enable: widget.enable,
                    onDragDone: (details) {
                      if (_validateUrls(details.urls)) {
                        widget.onOpenFiles(details.urls.map<String>((url)
                            => url.toFilePath()).toList());
                      }
                    },
                    onDragUpdated: (details) {},
                    onDragEntered: (details) {
                      setState(() {
                        _dragging = true;
                      });
                    },
                    onDragExited: (detail) {
                      setState(() {
                        _dragging = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download, size: 50.0),
                        const SizedBox(height: 7.0),
                        SizedBox(
                          width: 130.0,
                          child: Text(
                            widget.msg,
                            style: const TextStyle(fontSize: 11.0),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: Colors.black.withOpacity(_getOpacity()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _validateUrls(List<Uri> urls) {
    if (widget.maxFiles == 0) {
      // no files allowed
      return false;
    } else if (widget.maxFiles > 0) {
      if (urls.length > widget.maxFiles) {
        // to many files
        widget.onInvalidFiles();
        return false;
      }
    }
    if (widget.extensions.isNotEmpty) {
      for (final url in urls) {
        if (!widget.extensions
            .contains(url.toFilePath()
            .split('.')
            .last
            .toLowerCase())) {
          // invalid extension
          widget.onInvalidFiles();
          return false;
        }
      }
    }
    return true;
  }

  _getOpacity() {
    return (_dragging || !widget.enable) ? 0.1 : 0.0;
  }
}
