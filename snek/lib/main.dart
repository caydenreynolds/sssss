import 'package:flutter/material.dart';
import 'package:snek/fang.dart';
import 'package:snek/generic/bool_select.dart';
import 'package:snek/generic/map_select.dart';
import 'package:snek/model/folder_model.dart';
import 'package:snek/page/browse.dart';
import 'package:snek/page/login.dart';
import 'package:snek/model/auth_model.dart';
import 'package:provider/provider.dart';
import 'package:snek/page/signup.dart';
import 'package:snek/proto/auth.pb.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    // Just assume this'll be done by the time we actually need it
    init_fang();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData(
        canvasColor: Colors.black,
        primarySwatch: Colors.deepPurple,
        textTheme: Typography.whiteCupertino,
        errorColor: Colors.red,
        hintColor: Colors.white38,
        hoverColor: Colors.deepPurple[800],
        inputDecorationTheme: const InputDecorationTheme (
          enabledBorder: OutlineInputBorder(borderSide: BorderSide (
            color: Colors.white38,
          )),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(
            color: Colors.deepPurple,
          )),
        ),
        dialogBackgroundColor: Colors.grey[800],
      ),
      themeMode: ThemeMode.dark,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthModel()),
          ChangeNotifierProvider(create: (context) => FolderModel()),
        ],
        child: MyPageController()
      ),
    );
  }
}

class MyPageController extends StatefulWidget {
  MyPageController({Key? key,}) : super(key: key);
  
  final navBarPadding = 5.0;

  @override
  State<MyPageController> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyPageController> {
  SnekPage _page = SnekPage.Login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: const Text("Snek"),
        ),
      ),
      drawer: Drawer (
        child: Scaffold(
          appBar: AppBar(),
          body: Consumer<AuthModel> (
            builder: (context, model, child) => BoolSelect (
              condition: model.loggedIn(),
              trueBuilder: () => ListView (
                children: [
                  buildNavBarButton(context, SnekPage.Search),
                  buildNavBarButton(context, SnekPage.File_Browser),
                  buildNavBarButton(context, SnekPage.My_Account),
                ],
              ),
              falseBuilder: () => ListView (
                children: [
                  buildNavBarButton(context, SnekPage.Login),
                  buildNavBarButton(context, SnekPage.Signup),
                ],
              ),
            )
          ),
        ),
      ),
      body: Consumer<AuthModel> (
        builder: (context, model, child) => Container(
          alignment: Alignment.center,
          child: MapSelect<SnekPage> (
            mapKey: _page,
            builders: {
              SnekPage.Login: () => LoginPage(callback: (token) => handleLogin(context, token)),
              SnekPage.Signup: () => SignupPage(callback: (token) => handleLogin(context, token)),
              SnekPage.File_Browser: () => BrowserPage(token: model.getToken()),
              SnekPage.My_Account: () => Text("My account page"),
            },
          )
        ),
      )
    );
  }

  void handleLogin(BuildContext context, AuthToken token) {
    setState(() {
      _page = SnekPage.File_Browser;
    });
    Provider.of<AuthModel>(context, listen: false).login(token);
  }

  Widget buildNavBarButton(BuildContext context, SnekPage page) {
    return ListTile (
      title: Container (
        alignment: Alignment.center,
        child: Text(ppSnekPage(page)),
      ),
      onTap: () => {
        setState(() => _page = page),
        Navigator.pop(context)
      },
    );
  }
}

enum SnekPage {
  Login,
  Signup,
  My_Account,
  File_Browser,
  View_File,
  Search,
}

String ppSnekPage(SnekPage page) {
  return page.name.replaceAll("_", " ");
}
