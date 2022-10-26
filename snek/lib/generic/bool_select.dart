import 'package:flutter/material.dart';

class BoolSelect extends StatelessWidget {
  /// Map select allows you to supply two builders and a boolean condition
  /// If the condition is true, the true_builder will be executed
  /// Otherwise, the false_builder will be executed
  const BoolSelect({
    Key? key,
    required this.trueBuilder,
    required this.falseBuilder,
    required this.condition
  }): super(key: key);

  final Widget Function() trueBuilder;
  final Widget Function() falseBuilder;
  final bool condition;

  @override
  Widget build(BuildContext context) {
    return condition ? trueBuilder() : falseBuilder();
  }
}
