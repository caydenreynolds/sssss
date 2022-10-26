@JS()
library fang;

import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
abstract class Promise<T> {
  external factory Promise(
      void executor(void resolve(T result), Function reject));
  external Promise then(void onFulfilled(T result), [Function onRejected]);
}

@JS('init')
external Promise<void> init_fang();

@JS('crypto_hash')
external Uint8List crypto_hash(String data);

// @JS('add')
// external int add(int a, int b);
//
// @JS('str_pass_through')
// external String str_pass_through(String arg);
//
// @JS('deflateFang')
// external List<int> deflateFang(List<int> arg);
//
// @JS('to_json')
// external String to_json(String a, int b, String c, String d, String e, String f, String g, int times);
//
// bool _isInit = false;
//
// Future<void> checkInit() async {
//   if (!_isInit) {
//     await promiseToFuture(init());
//     _isInit = true;
//   }
// }
//
// Future<int> fangAdd(int a, int b) async {
//   await checkInit();
//   return add(a, b);
// }
//
// Future<String> fangStrPassThrough(String arg) async {
//   await checkInit();
//   return str_pass_through(arg);
// }
//
// Future<String> fangToJson(String a, int b, String c, String d, String e, String f, String g, int times) async {
//   await checkInit();
//   return to_json(a, b, c, d, e, f, g, times);
// }
//
// Future<List<int>> fangDeflate(List<int> bytes) async {
//   await checkInit();
//   return deflateFang(bytes);
// }
