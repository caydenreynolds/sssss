import 'package:flutter/material.dart';

class MapSelect<K> extends StatelessWidget {
  /// Map select allows you to supply a map of keys to builder functions
  /// And a mapKey
  /// When building, only the builder that corresponds to mapKey will be executed
  /// Providing an efficient way to select one widget from a set of options
  const MapSelect({
    Key? key,
    required this.builders,
    required this.mapKey
  }): super(key: key);

  final Map<K, Widget Function()> builders;
  final K mapKey;

  @override
  Widget build(BuildContext context) {
    var builder = builders[mapKey];
    if (builder == null) {
      throw Exception("Failed to build MapSelect: No value for key $mapKey");
    } else {
      return builder();
    }
  }
}
