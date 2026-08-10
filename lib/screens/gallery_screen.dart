import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/theme/app_colors.dart';
import '../models/album_model.dart';
import '../services/cloudinary_service.dart';
import '../services/selection_service.dart';
import 'photo_viewer_screen.dart';

class GalleryScreen extends StatefulWidget {
  final AlbumModel album;
  final AlbumDay day;
  final AlbumFolder folder;

  const GalleryScreen({
    super.key,
    required this.album,
    required this.day,
    required this.folder,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // ==========================================
  // SELECTION SERVICE
  // ==========================================

  final SelectionService _selectionService = SelectionService.instance;

  // ==========================================
  // CURRENT CAMERA SELECTED COUNT
  // ==========================================

  int get currentCameraSelectedCount {
    return _selectionService.selectedCount(
      albumCode: widget.album.albumCode,
      dayName: widget.day.name,
      cameraName: widget.folder.name,
    );
  }

  // ==========================================
  // TOTAL SELECTED IN COMPLETE ALBUM
  //
  // ALL DAYS + ALL CAMERAS
  // ==========================================

  int get totalAlbumSelectedCount {
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
  // INIT STATE
  // ==========================================

  @override
  void initState() {
    super.initState();

    _selectionService.addListener(_selectionChanged);

    // Make sure saved selections are loaded
    // whenever GalleryScreen opens.
    _selectionService.loadSelections();
  }

  // ==========================================
  // SELECTION CHANGED
  // ==========================================

  void _selectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    _selectionService.removeListener(_selectionChanged);

    super.dispose();
  }

  // ==========================================
  // TOGGLE PHOTO SELECTION
  // ==========================================

  Future<void> _toggleSelection(String photo) async {
    await _selectionService.toggleSelection(
      albumCode: widget.album.albumCode,
      dayName: widget.day.name,
      cameraName: widget.folder.name,
      photo: photo,
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),

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

        title: Column(
          children: [
            Text(
              widget.album.clientName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              "${widget.day.name} • ${widget.folder.name}",
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        // ======================================
        // CURRENT CAMERA SELECTED
        // ======================================
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  "Selected: $currentCameraSelectedCount",

                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ========================================
      // BODY
      // ========================================
      body: Column(
        children: [
          // ====================================
          // CAMERA INFORMATION CARD
          // ====================================
          Container(
            width: double.infinity,

            margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: const Color(0xFF171717),

              borderRadius: BorderRadius.circular(20),

              border: Border.all(color: AppColors.primaryGold.withOpacity(.35)),

              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(.08),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,

                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 34,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.folder.name,

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "${widget.folder.count} Photos",

                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),

                      if (currentCameraSelectedCount > 0) ...[
                        const SizedBox(height: 5),

                        Text(
                          "$currentCameraSelectedCount Selected",

                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ====================================
          // TOTAL SELECTED
          //
          // COMPLETE ALBUM TOTAL
          // ALL DAYS + ALL CAMERAS
          // ====================================
          Container(
            width: double.infinity,

            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),

            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

            decoration: BoxDecoration(
              color: const Color(0xFF171717),

              borderRadius: BorderRadius.circular(16),

              border: Border.all(color: AppColors.primaryGold.withOpacity(.30)),
            ),

            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,

                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.favorite,
                    color: Colors.black,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    "TOTAL SELECTED",

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                Text(
                  "$totalAlbumSelectedCount Photos",

                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ====================================
          // PHOTO GRID
          // ====================================
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),

              itemCount: widget.folder.photos.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .82,
              ),

              itemBuilder: (context, index) {
                final photo = widget.folder.photos[index];

                final imageUrl = CloudinaryService.imageUrl(
                  albumCode: widget.album.albumCode,
                  day: widget.day.name,
                  camera: widget.folder.name,
                  photo: photo,
                );

                // =================================
                // IS PHOTO SELECTED?
                // =================================

                final isSelected = _selectionService.isSelected(
                  albumCode: widget.album.albumCode,
                  dayName: widget.day.name,
                  cameraName: widget.folder.name,
                  photo: photo,
                );

                return GestureDetector(
                  // =================================
                  // OPEN FULL IMAGE
                  // =================================
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoViewerScreen(
                          photos: widget.folder.photos,

                          initialIndex: index,

                          albumCode: widget.album.albumCode,

                          dayName: widget.day.name,

                          folderName: widget.folder.name,
                        ),
                      ),
                    );
                  },

                  child: Hero(
                    tag: imageUrl,

                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGold
                              : AppColors.primaryGold.withOpacity(.20),

                          width: isSelected ? 3 : 1,
                        ),

                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGold.withOpacity(.30),

                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),

                        child: Stack(
                          fit: StackFit.expand,

                          children: [
                            // =====================
                            // IMAGE
                            // =====================
                            CachedNetworkImage(
                              imageUrl: imageUrl,

                              fit: BoxFit.cover,

                              fadeInDuration: Duration.zero,

                              fadeOutDuration: Duration.zero,

                              memCacheWidth: 350,

                              maxWidthDiskCache: 350,

                              placeholder: (context, url) {
                                return Container(
                                  color: const Color(0xFF202020),

                                  child: const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                );
                              },

                              errorWidget: (context, url, error) {
                                return Container(
                                  color: const Color(0xFF202020),

                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.white54,
                                      size: 34,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // =====================
                            // SELECTED OVERLAY
                            // =====================
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.18),

                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),

                            // =====================
                            // HEART / CHECK BUTTON
                            // =====================
                            Positioned(
                              top: 7,
                              right: 7,

                              child: GestureDetector(
                                onTap: () async {
                                  await _toggleSelection(photo);
                                },

                                child: Container(
                                  width: 34,
                                  height: 34,

                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryGold
                                        : Colors.black.withOpacity(.65),

                                    shape: BoxShape.circle,

                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryGold
                                          : Colors.white54,

                                      width: 1.2,
                                    ),
                                  ),

                                  child: Icon(
                                    isSelected
                                        ? Icons.check
                                        : Icons.favorite_border,

                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,

                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

                            // =====================
                            // PHOTO NAME
                            // =====================
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 5,
                                ),

                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,

                                    end: Alignment.topCenter,

                                    colors: [
                                      Colors.black87,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),

                                child: Text(
                                  photo,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  textAlign: TextAlign.center,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
