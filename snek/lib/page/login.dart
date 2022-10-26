import 'package:flutter/material.dart';
import 'package:snek/client/auth.dart';
import 'package:snek/generic/padded_column.dart';
import 'package:snek/proto/auth.pb.dart';

class LoginPage extends StatefulWidget {
  /// Page that attempts to get login from user, and executes callback once successful
  LoginPage({Key? key, required this.callback}) : super(key: key);

  final void Function(AuthToken) callback;
  final formKey = GlobalKey<FormState>();

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = "";
  String _password = "";
  String? _errUser;
  String? _errPass;

  @override
  Widget build(BuildContext context) {
    const entryWidth = 300.0;
    const entryHeight = 50.0;
    return Form(
        key: widget.formKey,
        child: PaddedColumn(
          padding: 15.0,
          children: [
            Container(
              width: entryWidth,
              height: entryHeight,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Username",
                  errorText: _errUser,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (text) => _username = text!,
              ),
            ),
            Container(
              width: entryWidth,
              height: entryHeight,
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  errorText: _errPass,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (text) => _password = text!,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  var state = widget.formKey.currentState!;
                  if (state.validate()) {
                    state.save();
                    tryLogin(widget.callback);
                  }
                },
                child: const Text("Login")),
          ],
        ));
  }

  void tryLogin(void Function(AuthToken) callback) async {
    /// Attempts to login, and executes callback if successful
    try {
      var token = await login(_username, _password);
      callback(token);
    } catch (e) {
      var err = e.toString();
      var lower_err = err.toLowerCase();
      var displayed = false;
      if (lower_err.contains("password")) {
        setState(() {
          _errPass = err;
        });
        displayed = true;
      }
      if (lower_err.contains("username")) {
        setState(() {
          _errUser = err;
        });
        displayed = true;
      }
      if (!displayed) {
        setState(() {
          _errUser = err;
          _errPass = err;
        });
      }
    }
  }
}
