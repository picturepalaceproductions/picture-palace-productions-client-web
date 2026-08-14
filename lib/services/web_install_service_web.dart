import 'dart:js_interop';

@JS('picturePalaceIsStandalone')
external bool _picturePalaceIsStandalone();

@JS('picturePalaceInstall')
external JSPromise<JSBoolean> _picturePalaceInstall();

class WebInstallService {
  static bool get isWeb => true;

  static Future<bool> isStandalone() async {
    try {
      return _picturePalaceIsStandalone();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> tryInstall() async {
    try {
      final result = await _picturePalaceInstall().toDart;
      return result.toDart;
    } catch (_) {
      return false;
    }
  }
}
