import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // ==========================================
  // CLOUDINARY
  // ==========================================

  static const String cloudName = "gs7boqwd";

  // ==========================================
  // URL ENCODE
  // ==========================================

  static String _encode(String value) {
    return Uri.encodeComponent(value);
  }

  // ==========================================
  // REMOVE IMAGE EXTENSION
  // ==========================================

  static String _removeExtension(String photo) {
    return photo
        .replaceAll(".JPG", "")
        .replaceAll(".jpg", "")
        .replaceAll(".JPEG", "")
        .replaceAll(".jpeg", "");
  }

  // ==========================================
  // GALLERY THUMBNAIL
  // ==========================================

  static String imageUrl({
    required String albumCode,
    required String day,
    required String camera,
    required String photo,
  }) {
    final publicId = _removeExtension(photo);

    return "https://res.cloudinary.com/"
        "$cloudName/image/upload/"
        "c_fill,w_350,h_350,q_auto,f_auto/"
        "albums/"
        "${_encode(albumCode)}/"
        "${_encode(day)}/"
        "${_encode(camera)}/"
        "$publicId.jpg";
  }

  // ==========================================
  // FULL SCREEN VIEWER
  // ==========================================

  static String viewerImageUrl({
    required String albumCode,
    required String day,
    required String camera,
    required String photo,
  }) {
    final publicId = _removeExtension(photo);

    return "https://res.cloudinary.com/"
        "$cloudName/image/upload/"
        "w_1400,q_auto,f_auto/"
        "albums/"
        "${_encode(albumCode)}/"
        "${_encode(day)}/"
        "${_encode(camera)}/"
        "$publicId.jpg";
  }

  // ==========================================
  // UPLOAD SELECTION JSON
  // ==========================================

  static Future<String?> uploadSelectionJson({
    required String albumCode,
    required String jsonData,
  }) async {
    try {
      debugPrint("========================================");
      debugPrint("Uploading Selection JSON...");
      debugPrint("Album: $albumCode");
      debugPrint("========================================");

      // ========================================
      // CLOUDINARY RAW UPLOAD URL
      // ========================================

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/raw/upload",
      );

      final request = http.MultipartRequest("POST", uri);

      // ========================================
      // UNSIGNED UPLOAD PRESET
      // ========================================

      request.fields["upload_preset"] = "picture_palace_selection";

      // ========================================
      // SELECTION FOLDER
      // ========================================

      request.fields["folder"] = "albums/$albumCode/selections";

      // ========================================
      // UNIQUE FILE NAME
      //
      // हर बार नया JSON बनेगा
      // पुरानी selection सुरक्षित रहेगी
      // ========================================

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final publicId = "${albumCode}_selection_$timestamp.json";

      request.fields["public_id"] = publicId;

      // ========================================
      // JSON FILE
      // ========================================

      request.files.add(
        http.MultipartFile.fromString("file", jsonData, filename: publicId),
      );

      // ========================================
      // DEBUG INFORMATION
      // ========================================

      debugPrint("Selection Public ID: $publicId");

      debugPrint(
        "Selection Folder: "
        "albums/$albumCode/selections",
      );

      // ========================================
      // SEND REQUEST
      // ========================================

      final response = await request.send();

      final body = await response.stream.bytesToString();

      // ========================================
      // RESPONSE
      // ========================================

      debugPrint("Cloudinary Status: ${response.statusCode}");

      debugPrint("Cloudinary Response:");

      debugPrint(body);

      // ========================================
      // SUCCESS
      // ========================================

      if (response.statusCode == 200) {
        final data = jsonDecode(body);

        final secureUrl = data["secure_url"]?.toString();

        debugPrint("========================================");

        debugPrint("Selection JSON Uploaded Successfully");

        debugPrint("Selection URL: $secureUrl");

        debugPrint("========================================");

        return secureUrl;
      }

      // ========================================
      // FAILED
      // ========================================

      debugPrint("========================================");

      debugPrint("Selection JSON Upload Failed");

      debugPrint("Status: ${response.statusCode}");

      debugPrint(body);

      debugPrint("========================================");

      return null;
    } catch (e, stackTrace) {
      // ========================================
      // ERROR
      // ========================================

      debugPrint("========================================");

      debugPrint("Selection JSON Upload Error:");

      debugPrint(e.toString());

      debugPrint("========================================");

      debugPrint(stackTrace.toString());

      return null;
    }
  }
}
