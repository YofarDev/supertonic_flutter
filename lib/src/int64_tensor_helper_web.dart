import 'dart:js_interop';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
// ignore: implementation_imports
import 'package:flutter_onnxruntime/src/flutter_onnxruntime_platform_interface.dart';

@JS('BigInt')
external JSBigInt _bigInt(JSAny value);

Future<OrtValue> createInt64Tensor(List<int> values, List<int> dims) async {
  final jsBigInts = values.map((v) => _bigInt(v.toJS)).toList(growable: false);
  final map = await FlutterOnnxruntimePlatform.instance.createOrtValue(
    'int64',
    jsBigInts,
    dims,
  );
  return OrtValue.fromMap(map);
}
