import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:snek/client/util.dart';
import 'package:snek/proto/auth.pb.dart';
import 'package:snek/proto/auth.pbgrpc.dart';
import 'package:grpc/grpc_web.dart';
import 'package:snek/proto/file.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:snek/proto/void.pb.dart';

import '../except.dart';

final fileStub = FileServiceClient(grpcChannel);

Future<FileMetadata> getRootFolder(AuthToken token) async {
  try {
    var response = await fileStub.getRootFolder(token);
    return response;
  } on GrpcError catch (e) {
    throw UserException(e.message!);
  }
}

Future<Void> createFolder(AuthToken token, Int64 parentId, String name) async {
  var cf = CreateFolder(parentId: FileId(id: parentId), name: name);
  var cfr = CreateFolderRequest(authToken: token, request: cf);
  try {
    var response = await fileStub.createFolder(cfr);
    return response;
  } on GrpcError catch (e) {
    throw UserException(e.message!);
  }
}

Future<Void> createFile(AuthToken token, Int64 parentId, String name, Stream<List<int>> bytesStream) async {
  var cf = CreateFile(name: name, parentId: FileId(id: parentId));
  var cfr = CreateFileRequest(authToken: token, request: cf);
  try {
    var response = await fileStub.createFile(cfr);
    var req = http.StreamedRequest("POST", Uri.http('localhost:8008/', ''));
    await for (var bytes in bytesStream) {
      req.sink.add(bytes);
    }
    return Void();
  } on GrpcError catch(e) {
    throw UserException(e.message);
  }
}

ResponseStream<FolderContents> folderContentsStream(AuthToken token, Int64 parentId) {
  var getContents = GetContents(folderId: parentId);
  var request = GetContentsRequest(authToken: token, request: getContents);
  try {
    return fileStub.getFolderContents(request, options: callOptions);
  } on GrpcError catch (e) {
    throw UserException(e.message!);
  }
}
