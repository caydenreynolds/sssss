import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/folder_model.dart';
import '../pojo/file_data.dart';

class PathNavigator extends StatelessWidget {
  const PathNavigator({Key? key, required this.path}) : super(key: key);

  final List<FileData> path;

  @override
  Widget build(BuildContext context) {
    return Row (
      children: path.map((p) => NavigatorElement(fileData: p)).toList(),
    );
  }
}

class NavigatorElement extends StatelessWidget {
  const NavigatorElement({Key? key, required this.fileData}) : super(key: key);

  final FileData fileData;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Provider.of<FolderModel>(context, listen: false).pop(fileData),
        child: Text(
            fileData.getPathName(),
            style: const TextStyle (
              decoration: TextDecoration.underline,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
        )
    );
  }
}
