class AppConfig {
  AppConfig._();

  // ==============================
  // Cloudinary
  // ==============================

  static const String cloudName = "gs7boqwd";

  // Base URL for Images
  static const String imageBaseUrl =
      "https://res.cloudinary.com/gs7boqwd/image/upload/";

  // ==============================
  // Firestore
  // ==============================

  static const String albumCollection = "albums";

  static const String selectionCollection = "selections";
}
