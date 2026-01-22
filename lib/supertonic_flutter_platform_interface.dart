import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'supertonic_flutter_method_channel.dart';

abstract class SupertonicFlutterPlatform extends PlatformInterface {
  /// Constructs a SupertonicFlutterPlatform.
  SupertonicFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static SupertonicFlutterPlatform _instance = MethodChannelSupertonicFlutter();

  /// The default instance of [SupertonicFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelSupertonicFlutter].
  static SupertonicFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SupertonicFlutterPlatform] when
  /// they register themselves.
  static set instance(SupertonicFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
