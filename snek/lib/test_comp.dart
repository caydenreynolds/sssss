import 'dart:typed_data';

import 'package:archive/archive.dart';

List<int> deflate(List<int> bytes) {
  return Deflate(bytes).getBytes();
}
