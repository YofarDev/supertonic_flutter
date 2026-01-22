import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'supertonic_flutter_platform_interface.dart';

/// An implementation of [SupertonicFlutterPlatform] that uses method channels.
class MethodChannelSupertonicFlutter extends SupertonicFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('supertonic_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
