import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snek/generic/bool_select.dart';
import 'package:snek/model/folder_model.dart';
import 'package:snek/proto/auth.pb.dart';
import 'package:snek/widget/file_grid.dart';
import 'package:snek/widget/path_navigator.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({Key? key, required this.token}) : super(key: key);

  final AuthToken token;

  @override
  State<StatefulWidget> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<FolderModel>(context, listen: false);
    if (!provider.ready()) {
      provider.getRoot(widget.token);
    }

    return Consumer<FolderModel>(
      builder: (context, model, child) => BoolSelect(
          condition: model.ready(),
          trueBuilder: () => Column(
            children: [
              PathNavigator(path: model.getAll()),
              Expanded(
                  child: FileGrid(token: widget.token, currentFolder: model.peek())
              ),
            ],
          ),
          falseBuilder: ()=> const Text("Loading..."),
      ),
    );
  }
}
