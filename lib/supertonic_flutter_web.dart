import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'supertonic_flutter_platform_interface.dart';

/// Web implementation of [SupertonicFlutterPlatform].
class SupertonicFlutterWebPlugin extends SupertonicFlutterPlatform {
  /// Registers this plugin for web.
  static void registerWith(Registrar registrar) {
    SupertonicFlutterPlatform.instance = SupertonicFlutterWebPlugin();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return 'Web';
  }
}
