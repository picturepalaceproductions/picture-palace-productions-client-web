import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/album_model.dart';

class AlbumService {
  const AlbumService();

  Future<AlbumModel?> openAlbum(String albumCode) async {
    try {
      debugPrint("Loading Album JSON...");

      final url =
          "https://res.cloudinary.com/${AppConfig.cloudName}/raw/upload/albums/$albumCode/${albumCode}_album.json";

      debugPrint(url);

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint("HTTP Error : ${response.statusCode}");
        return null;
      }

      debugPrint("Album JSON Downloaded");

      final Map<String, dynamic> jsonData = json.decode(response.body);

      debugPrint("Album Parsed Successfully");

      return AlbumModel.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint("Album Load Failed");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      return null;
    }
  }
}
