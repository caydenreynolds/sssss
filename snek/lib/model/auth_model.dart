import 'package:flutter/material.dart';
import 'package:snek/proto/auth.pb.dart';

class AuthModel extends ChangeNotifier {
  AuthToken? _token;

  bool loggedIn() => _token != null;
  AuthToken getToken() => _token!;

  void login(AuthToken token) {
    _token = token;
    notifyListeners();
  }
}
