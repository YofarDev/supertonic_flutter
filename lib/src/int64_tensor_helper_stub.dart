import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

Future<OrtValue> createInt64Tensor(List<int> values, List<int> dims) async {
  return OrtValue.fromList(Int64List.fromList(values), dims);
}
