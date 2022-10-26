import 'package:flutter/material.dart';

class PaddedColumn extends StatelessWidget {
  /// Extension of column type that automatically puts vertical padding between all elements
  /// Padding is also added at the top and bottom of the column
  PaddedColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
    double padding = 0,
  }) : super(key: key) {
    var padBox = SizedBox(height: padding,);
    List<Widget> paddedChildren = [padBox];
    children.forEach((element) {
      paddedChildren.add(element);
      paddedChildren.add(padBox);
    });
    column = Column(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: paddedChildren,
    );
  }

  late final Column column;

  @override
  Widget build(BuildContext context) {
    return column;
  }
}
