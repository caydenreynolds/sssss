import 'dart:convert';

import 'package:snek/fang.dart';
import 'proto/venom.pb.dart';

class TestMessage {
  List<int> auth_token = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
  int req_type = 12;
  String file_name = "Project final 2 final (I mean it this time).docx";
  String search_string = "Project final tag:school dateMin:2019:00:00 dateMax 2020:00:00";
  String directory = "school/projects/final_projects";
  String username = "ur mom";
  String password = "my d!ck";

  String toJsonNative() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_token': auth_token,
      'req_type': req_type,
      'file_name': file_name,
      'search_string': search_string,
      'directory': directory,
      'username': username,
      'password': password,
    };
  }

  // Future<String> toJsonWasm(int times) async {
  //   return await fangToJson(auth_token, req_type, file_name, search_string, directory, username, password, times);
  // }

  String toJsonProtobuf() {
    var msg = VenomMessage();
    msg.authToken = auth_token;
    msg.msgType = req_type;
    msg.fileName = file_name;
    msg.searchString = search_string;
    msg.directory = directory;
    msg.username = username;
    msg.password = password;

    return String.fromCharCodes(msg.writeToBuffer());
  }
}
