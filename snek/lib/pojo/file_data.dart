import 'package:flutter/material.dart';
import 'package:snek/proto/file.pb.dart';
import 'package:fixnum/fixnum.dart';

class FileData {
  FileData(this.metadata);

  final FileMetadata metadata;

  String getName() {
    return metadata.name;
  }

  // Just like getName, but adds a trailing forward slash if this is a folder
  String getPathName() {
    if (metadata.type == FileType.FOLDER) {
      return "${metadata.name}/";
    } else {
      return metadata.name;
    }
  }

  Int64 getId() {
    return metadata.id;
  }

  IconData preferredIcon() {
    switch (metadata.type) {
      case FileType.FILE:
        return Icons.insert_drive_file;
      case FileType.FOLDER:
        return Icons.folder;
      default:
        throw Exception("TODO");
    }
  }
}
