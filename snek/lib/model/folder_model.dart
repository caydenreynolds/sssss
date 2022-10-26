import 'package:flutter/material.dart';
import 'package:snek/client/file.dart';
import 'package:snek/pojo/file_data.dart';
import 'package:snek/proto/auth.pb.dart';

class FolderModel extends ChangeNotifier {
  List<FileData> _currentFolders = [];

  bool ready() => _currentFolders.isNotEmpty;
  FileData peek() => _currentFolders[_currentFolders.length-1];
  List<FileData> getAll() => _currentFolders;

  void push(FileData fd) {
    _currentFolders.add(fd);
    notifyListeners();
  }

  void getRoot(AuthToken token) async {
    push(FileData(await getRootFolder(token)));
  }

  // Removes elements from the folders until the given filedata is on top of the stack
  void pop(FileData until) {
    var index = _currentFolders.indexOf(until);
    _currentFolders.removeRange(index+1, _currentFolders.length);
    notifyListeners();
  }
}
