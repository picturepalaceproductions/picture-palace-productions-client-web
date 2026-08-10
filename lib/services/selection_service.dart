import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectionService extends ChangeNotifier {
  SelectionService._();

  static final SelectionService instance = SelectionService._();

  // ============================================================
  // SELECTION STORAGE
  // albumCode + day + camera
  //          ↓
  //     Set<String> photos
  // ============================================================

  final Map<String, Set<String>> _selections = <String, Set<String>>{};

  // ============================================================
  // STORAGE KEY
  // ============================================================

  static const String _storageKey = "picture_palace_selections";

  // ============================================================
  // LOAD STATE
  // ============================================================

  bool _isLoaded = false;

  Future<void>? _loadFuture;

  bool get isLoaded => _isLoaded;

  // ============================================================
  // SAVE QUEUE
  // ============================================================

  Future<void> _saveQueue = Future<void>.value();

  // ============================================================
  // CREATE UNIQUE FOLDER KEY
  // ============================================================

  String _folderKey({
    required String albumCode,
    required String dayName,
    required String cameraName,
  }) {
    return "$albumCode|$dayName|$cameraName";
  }

  // ============================================================
  // LOAD SAVED SELECTIONS
  // ============================================================

  Future<void> loadSelections() {
    if (_isLoaded) {
      return Future<void>.value();
    }

    if (_loadFuture != null) {
      return _loadFuture!;
    }

    _loadFuture = _loadSelectionsInternal();

    return _loadFuture!;
  }

  Future<void> _loadSelectionsInternal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedData = prefs.getString(_storageKey);

      debugPrint("========================================");
      debugPrint("SELECTION STORAGE LOAD");
      debugPrint("Data Found: ${savedData != null}");
      debugPrint("========================================");

      if (savedData == null || savedData.isEmpty) {
        _selections.clear();
        _isLoaded = true;

        debugPrint("No previous selections found.");

        notifyListeners();
        return;
      }

      final decoded = jsonDecode(savedData);

      if (decoded is! Map) {
        _selections.clear();
        _isLoaded = true;

        debugPrint("Invalid selection storage format.");

        notifyListeners();
        return;
      }

      _selections.clear();

      decoded.forEach((key, value) {
        if (value is List) {
          final photos = value.map<String>((item) => item.toString()).toSet();

          if (photos.isNotEmpty) {
            _selections[key.toString()] = photos;
          }
        }
      });

      _isLoaded = true;

      debugPrint("========================================");
      debugPrint("SELECTIONS LOADED SUCCESSFULLY");
      debugPrint("Folders: ${_selections.length}");
      debugPrint("Total Photos: $totalSelected");
      debugPrint("========================================");

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("========================================");
      debugPrint("SELECTION LOAD FAILED");
      debugPrint("$e");
      debugPrint("$stackTrace");
      debugPrint("========================================");

      _selections.clear();
      _isLoaded = true;

      notifyListeners();
    }
  }

  // ============================================================
  // SAVE SELECTIONS
  // ============================================================

  Future<void> _saveSelections() {
    _saveQueue = _saveQueue.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();

        final Map<String, dynamic> data = <String, dynamic>{};

        _selections.forEach((key, photos) {
          if (photos.isNotEmpty) {
            data[key] = photos.toList();
          }
        });

        final encodedData = jsonEncode(data);

        final success = await prefs.setString(_storageKey, encodedData);

        debugPrint("========================================");
        debugPrint("SELECTION STORAGE SAVE");
        debugPrint("Success: $success");
        debugPrint("Folders: ${_selections.length}");
        debugPrint("Total Photos: $totalSelected");
        debugPrint("========================================");
      } catch (e, stackTrace) {
        debugPrint("========================================");
        debugPrint("SELECTION SAVE FAILED");
        debugPrint("$e");
        debugPrint("$stackTrace");
      }
    });

    return _saveQueue;
  }

  // ============================================================
  // CHECK PHOTO SELECTED
  // ============================================================

  bool isSelected({
    required String albumCode,
    required String dayName,
    required String cameraName,
    required String photo,
  }) {
    final key = _folderKey(
      albumCode: albumCode,
      dayName: dayName,
      cameraName: cameraName,
    );

    return _selections[key]?.contains(photo) ?? false;
  }

  // ============================================================
  // SELECT / UNSELECT PHOTO
  // ============================================================

  Future<void> toggleSelection({
    required String albumCode,
    required String dayName,
    required String cameraName,
    required String photo,
  }) async {
    await loadSelections();

    final key = _folderKey(
      albumCode: albumCode,
      dayName: dayName,
      cameraName: cameraName,
    );

    final photos = _selections.putIfAbsent(key, () => <String>{});

    if (photos.contains(photo)) {
      photos.remove(photo);

      if (photos.isEmpty) {
        _selections.remove(key);
      }

      debugPrint("UNSELECTED: $photo");
    } else {
      photos.add(photo);

      debugPrint("SELECTED: $photo");
    }

    await _saveSelections();

    notifyListeners();
  }

  // ============================================================
  // CURRENT CAMERA SELECTED COUNT
  // ============================================================

  int selectedCount({
    required String albumCode,
    required String dayName,
    required String cameraName,
  }) {
    final key = _folderKey(
      albumCode: albumCode,
      dayName: dayName,
      cameraName: cameraName,
    );

    return _selections[key]?.length ?? 0;
  }

  // ============================================================
  // GET SELECTED PHOTOS
  // ============================================================

  Set<String> getSelectedPhotos({
    required String albumCode,
    required String dayName,
    required String cameraName,
  }) {
    final key = _folderKey(
      albumCode: albumCode,
      dayName: dayName,
      cameraName: cameraName,
    );

    return Set<String>.from(_selections[key] ?? <String>{});
  }

  // ============================================================
  // TOTAL SELECTED PHOTOS
  // ============================================================

  int get totalSelected {
    int total = 0;

    for (final photos in _selections.values) {
      total += photos.length;
    }

    return total;
  }

  // ============================================================
  // CLEAR EVERYTHING
  // ============================================================

  Future<void> clearAll() async {
    _selections.clear();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_storageKey);

      debugPrint("ALL SELECTIONS CLEARED");
    } catch (e) {
      debugPrint("Selection Clear Failed: $e");
    }

    notifyListeners();
  }
}
