class WebInstallService {
  static bool get isWeb => false;

  static Future<bool> isStandalone() async => false;

  static Future<bool> tryInstall() async => false;
}
