import 'package:flutter/material.dart';
import 'package:snek/client/file.dart';
import 'package:snek/generic/padded_column.dart';
import 'package:snek/proto/auth.pb.dart';
import 'package:grpc/grpc_web.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../model/folder_model.dart';
import '../pojo/file_data.dart';
import '../proto/file.pb.dart';

class FileGrid extends StatefulWidget {
  /// Page that attempts to get login from user, and executes callback once successful
  FileGrid({Key? key, required this.token, required this.currentFolder})
      : super(key: key);

  final AuthToken token;
  final FileData currentFolder;

  final popupPadding = 10.0;
  final popupWidth = 300.0;
  final popupHeight = 50.0;

  final createFolderKey = GlobalKey<FormState>();
  final uploadFileKey = GlobalKey<FormState>();

  @override
  State<StatefulWidget> createState() => _FileGridState();
}

class _FileGridState extends State<FileGrid> {
  List<FileData> _children = [];

  String? _errText, _folderName, _fileName;
  Future<FilePickerResult?>? _pickedFile;

  FileData? _currentlyListeningTo;

  ResponseStream<FolderContents>? _folderContentsStream;

  void _listenForFolderContents() async {
    _folderContentsStream = folderContentsStream(widget.token, widget.currentFolder.getId());
    // Wrap everything in a try so it can just error out when we cancel it later
    try {
      await for (var fc in _folderContentsStream!) {
        setState(() {
          _children = fc.contents.map((fm) => FileData(fm)).toList();
        });
      }
    } catch (_) {
      // Do nothing
    }

  }

  void _createFolder(BuildContext context,
      void Function(void Function() function) setState) async {
    try {
      await createFolder(
          widget.token, widget.currentFolder.getId(), _folderName!);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _errText = e.toString());
    }
  }

  void _createFile(BuildContext context,
      void Function(void Function() function) setState) async {
    print("UwU");
  }

  @override
  void dispose() {
    cancelStream();
    super.dispose();
  }

  void cancelStream() {
    if (_folderContentsStream != null) {
      _folderContentsStream!.cancel();
    }
  }

  void _createFolderDialog(BuildContext context) async {
    _errText = null;
    return showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Form(
            key: widget.createFolderKey,
            child: PaddedColumn(
              padding: widget.popupPadding,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.popupWidth,
                  height: widget.popupHeight,
                  padding: EdgeInsets.symmetric(horizontal: widget.popupPadding),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "folder_name",
                      errorText: _errText,
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a folder name';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9_\-\.]*$").hasMatch(value)) {
                        return 'Only allowed characters are A-Z, a-z, 0-9, _, -';
                      }
                      return null;
                    },
                    onSaved: (text) => _folderName = text!,
                  )
                ),
                ElevatedButton(
                  onPressed: () {
                    var state = widget.createFolderKey.currentState!;
                    if (state.validate()) {
                      state.save();
                      _createFolder(context, setState);
                    }
                  },
                  child: const Text("Create")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _uploadFileDialog(BuildContext context) async {
    _errText = null;
    _pickedFile = FilePicker.platform.pickFiles(withReadStream: true);
    final temp = await _pickedFile;
    temp.files.single.readStream
    return showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Form(
            key: widget.createFolderKey,
            child: PaddedColumn(
              padding: widget.popupPadding,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: widget.popupWidth,
                    height: widget.popupHeight,
                    padding: EdgeInsets.symmetric(horizontal: widget.popupPadding),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "file_name",
                        errorText: _errText,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a file name';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9_\-\.]*$").hasMatch(value)) {
                          return 'Only allowed characters are A-Z, a-z, 0-9, _, -';
                        }
                        return null;
                      },
                      onSaved: (text) => _fileName = text!,
                    )
                ),
                ElevatedButton(
                    onPressed: () {
                      var state = widget.createFolderKey.currentState!;
                      if (state.validate()) {
                        state.save();
                        _createFile(context, setState);
                      }
                    },
                    child: const Text("Create")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentlyListeningTo == null || _currentlyListeningTo != widget.currentFolder) {
      _currentlyListeningTo = widget.currentFolder;
      cancelStream();
      _listenForFolderContents();
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GridView.count(
            crossAxisCount: (constraints.widthConstraints().biggest.width / 150.0).floor(),
            children: _children.map((child) {
              return FileWidget(fileData: child);
            }).toList(),
          );
        },
      ),
      floatingActionButton: PaddedColumn(
        padding: 10.0,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _createFolderDialog(context),
            tooltip: 'Create a new folder',
            child: const Icon(Icons.create_new_folder),
          ),
          FloatingActionButton(
            onPressed: () => _uploadFileDialog(context),
            tooltip: 'Upload a new file',
            child: const Icon(Icons.upload_file),
          ),
        ],
      ),
    );
  }
}

class FileWidget extends StatelessWidget {
  const FileWidget({Key? key, required this.fileData}) : super(key: key);

  final FileData fileData;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: InkWell (
          child: PaddedColumn(
            padding: 1,
            children: [
              Icon(
                fileData.preferredIcon(),
                color: Colors.white,
                size: 100.0,
              ),
              Text(
                  fileData.getName()
              ),
            ],
          ),
          onTap: () => Provider.of<FolderModel>(context, listen: false).push(fileData),
        ),
      ),
    );
  }
}
