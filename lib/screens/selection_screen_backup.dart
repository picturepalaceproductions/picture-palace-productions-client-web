import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/album_model.dart';
import '../services/selection_service.dart';
import '../services/cloudinary_service.dart';
import 'gallery_screen.dart';

class SelectionScreen extends StatefulWidget {
  final AlbumModel album;

  const SelectionScreen({super.key, required this.album});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final SelectionService _selectionService = SelectionService.instance;

  bool _isSending = false;

  // ==========================================
  // LISTENER
  // ==========================================

  @override
  void initState() {
    super.initState();

    _selectionService.addListener(_selectionChanged);
  }

  void _selectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _selectionService.removeListener(_selectionChanged);

    super.dispose();
  }

  // ==========================================
  // TOTAL SELECTED
  // ==========================================

  int get totalSelected {
    int total = 0;

    for (final day in widget.album.days) {
      for (final folder in day.folders) {
        total += _selectionService.selectedCount(
          albumCode: widget.album.albumCode,
          dayName: day.name,
          cameraName: folder.name,
        );
      }
    }

    return total;
  }

  // ==========================================
  // DAY SELECTED COUNT
  // ==========================================

  int daySelectedCount(AlbumDay day) {
    int total = 0;

    for (final folder in day.folders) {
      total += _selectionService.selectedCount(
        albumCode: widget.album.albumCode,
        dayName: day.name,
        cameraName: folder.name,
      );
    }

    return total;
  }

  // ==========================================
  // OPEN CAMERA GALLERY
  // ==========================================

  void _openCameraGallery(AlbumDay day, AlbumFolder folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GalleryScreen(album: widget.album, day: day, folder: folder),
      ),
    );
  }

  // ==========================================
  // CREATE SELECTION JSON
  // ==========================================

  Map<String, dynamic> _createSelectionJson() {
    final List<Map<String, dynamic>> days = [];

    for (final day in widget.album.days) {
      final List<Map<String, dynamic>> cameras = [];

      for (final folder in day.folders) {
        final selectedPhotos = _selectionService.getSelectedPhotos(
          albumCode: widget.album.albumCode,
          dayName: day.name,
          cameraName: folder.name,
        );

        if (selectedPhotos.isEmpty) {
          continue;
        }

        cameras.add({
          "cameraName": folder.name,
          "selectedCount": selectedPhotos.length,
          "photos": selectedPhotos.toList(),
        });
      }

      if (cameras.isEmpty) {
        continue;
      }

      days.add({
        "dayName": day.name,
        "selectedCount": cameras.fold<int>(
          0,
          (sum, camera) => sum + (camera["selectedCount"] as int),
        ),
        "cameras": cameras,
      });
    }

    return {
      "version": 1,
      "type": "photo_selection",
      "albumCode": widget.album.albumCode,
      "clientName": widget.album.clientName,
      "totalSelected": totalSelected,
      "submittedOn": DateTime.now().toIso8601String(),
      "days": days,
    };
  }

  // ==========================================
  // CONFIRM & SEND
  // ==========================================

  Future<void> _confirmAndSend() async {
    if (_isSending) {
      return;
    }

    if (totalSelected == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one photo.")),
      );

      return;
    }

    // ========================================
    // DISCLAIMER
    // ========================================

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.black,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  "Confirm Your Selection",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "You are about to send your selected photos to Picture Palace Productions.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(.30),
                    ),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_library,
                        color: AppColors.primaryGold,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "Total Selected: $totalSelected Photos",
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "IMPORTANT",
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Please confirm that you have personally selected these photos. These are the photos you want Picture Palace Productions to process.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Once submitted, your selection will be sent to the studio for processing.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: const Text(
                "CANCEL",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              child: const Text(
                "I CONFIRM & SEND",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // ========================================
    // CREATE JSON
    // ========================================

    final selectionData = _createSelectionJson();

    final selectionJson = const JsonEncoder.withIndent(
      "  ",
    ).convert(selectionData);

    debugPrint("========================================");

    debugPrint("SELECTION JSON READY");

    debugPrint("========================================");

    debugPrint(selectionJson);

    // ========================================
    // START UPLOAD
    // ========================================

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    // ========================================
    // UPLOAD JSON TO CLOUDINARY
    // ========================================

    final selectionUrl = await CloudinaryService.uploadSelectionJson(
      albumCode: widget.album.albumCode,
      jsonData: selectionJson,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
    });

    // ========================================
    // UPLOAD FAILED
    // ========================================

    if (selectionUrl == null) {
      await showDialog(
        context: context,

        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF181818),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent, size: 30),

                SizedBox(width: 10),

                Text(
                  "Upload Failed",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            content: const Text(
              "Your selection could not be sent to the studio.\n\nPlease check your internet connection and try again.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      return;
    }

    // ========================================
    // SUCCESS
    // ========================================

    await showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Selection Sent Successfully",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          content: Text(
            "$totalSelected photos have been successfully sent to Picture Palace Productions.\n\nYour selection has been received by the studio.",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "OK",
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    debugPrint("========================================");

    debugPrint("SELECTION UPLOAD SUCCESS");

    debugPrint("Selection URL: $selectionUrl");

    debugPrint("========================================");
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),

      // ========================================
      // APP BAR
      // ========================================
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(Icons.favorite, color: AppColors.primaryGold, size: 21),

            const SizedBox(width: 8),

            const Text(
              "My Selection",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // ========================================
      // BODY
      // ========================================
      body: Column(
        children: [
          // ======================================
          // TOTAL SELECTED
          // ======================================
          Container(
            width: double.infinity,

            margin: const EdgeInsets.all(18),

            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: const Color(0xFF171717),

              borderRadius: BorderRadius.circular(22),

              border: Border.all(color: AppColors.primaryGold.withOpacity(.35)),

              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(.08),

                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),

            child: Column(
              children: [
                Container(
                  width: 65,
                  height: 65,

                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.favorite,
                    color: Colors.black,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "TOTAL SELECTED",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "$totalSelected Photos",
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ======================================
          // DAYS
          // ======================================
          Expanded(
            child: widget.album.days.isEmpty
                ? const Center(
                    child: Text(
                      "No Days Available",
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),

                    itemCount: widget.album.days.length,

                    itemBuilder: (context, index) {
                      final day = widget.album.days[index];

                      final dayCount = daySelectedCount(day);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        decoration: BoxDecoration(
                          color: const Color(0xFF181818),

                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(.30),
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(18),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // ==================
                              // DAY HEADER
                              // ==================
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,

                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold,

                                      borderRadius: BorderRadius.circular(14),
                                    ),

                                    child: Center(
                                      child: Text(
                                        "${index + 1}",

                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          day.name,

                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "$dayCount Photos Selected",

                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (dayCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),

                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold,

                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: Text(
                                        "$dayCount",

                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ==================
                              // CAMERA LIST
                              // ==================
                              ...day.folders.map((folder) {
                                final count = _selectionService.selectedCount(
                                  albumCode: widget.album.albumCode,
                                  dayName: day.name,
                                  cameraName: folder.name,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    _openCameraGallery(day, folder);
                                  },

                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),

                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),

                                    decoration: BoxDecoration(
                                      color: const Color(0xFF101010),

                                      borderRadius: BorderRadius.circular(14),

                                      border: Border.all(
                                        color: count > 0
                                            ? AppColors.primaryGold.withOpacity(
                                                .50,
                                              )
                                            : Colors.white12,
                                      ),
                                    ),

                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.photo_camera,

                                          color: count > 0
                                              ? AppColors.primaryGold
                                              : Colors.white54,

                                          size: 24,
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            folder.name,

                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        Text(
                                          "$count Selected",

                                          style: TextStyle(
                                            color: count > 0
                                                ? AppColors.primaryGold
                                                : Colors.white54,

                                            fontSize: 13,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        const Icon(
                                          Icons.arrow_forward_ios,

                                          color: Colors.white38,

                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ======================================
          // SEND TO STUDIO BUTTON
          // ======================================
          SafeArea(
            top: false,

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),

              decoration: const BoxDecoration(
                color: Colors.black,

                border: Border(top: BorderSide(color: Colors.white12)),
              ),

              child: SizedBox(
                height: 54,

                child: ElevatedButton.icon(
                  onPressed: totalSelected > 0 && !_isSending
                      ? _confirmAndSend
                      : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,

                    disabledBackgroundColor: Colors.white12,

                    foregroundColor: Colors.black,

                    disabledForegroundColor: Colors.white30,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined),

                  label: Text(
                    _isSending
                        ? "SENDING SELECTION..."
                        : "SEND SELECTION TO STUDIO",

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
