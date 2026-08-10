import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/cloudinary_service.dart';
import '../services/selection_service.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List photos;
  final int initialIndex;

  final String albumCode;
  final String dayName;
  final String folderName;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.albumCode,
    required this.dayName,
    required this.folderName,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _pageController;

  late int currentIndex;

  // ==========================================
  // Common Selection Service
  // ==========================================

  final SelectionService _selectionService = SelectionService.instance;

  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    _pageController = PageController(initialPage: widget.initialIndex);

    _selectionService.addListener(_selectionChanged);
  }

  // ==========================================
  // Selection Changed
  // ==========================================

  void _selectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================
  // Dispose
  // ==========================================

  @override
  void dispose() {
    _selectionService.removeListener(_selectionChanged);

    _pageController.dispose();

    super.dispose();
  }

  // ==========================================
  // Select / Unselect
  // ==========================================

  void _toggleSelection(String photo) {
    _selectionService.toggleSelection(
      albumCode: widget.albumCode,
      dayName: widget.dayName,
      cameraName: widget.folderName,
      photo: photo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[currentIndex];

    // ========================================
    // Common Selection Status
    // ========================================

    final isSelected = _selectionService.isSelected(
      albumCode: widget.albumCode,
      dayName: widget.dayName,
      cameraName: widget.folderName,
      photo: currentPhoto,
    );

    return Scaffold(
      backgroundColor: Colors.black,

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

        title: Text(
          "${currentIndex + 1} / ${widget.photos.length}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ======================================
        // Selection Button
        // ======================================
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: Center(
              child: GestureDetector(
                onTap: () {
                  _toggleSelection(currentPhoto);
                },

                child: Container(
                  width: 44,
                  height: 44,

                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber : Colors.black87,

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: isSelected ? Colors.amber : Colors.white54,

                      width: 1.5,
                    ),
                  ),

                  child: Icon(
                    isSelected ? Icons.check : Icons.favorite_border,

                    color: isSelected ? Colors.black : Colors.white,

                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          // ====================================
          // FULL SCREEN PHOTO
          // ====================================
          PageView.builder(
            controller: _pageController,

            itemCount: widget.photos.length,

            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },

            itemBuilder: (context, index) {
              final imageUrl = CloudinaryService.viewerImageUrl(
                albumCode: widget.albumCode,
                day: widget.dayName,
                camera: widget.folderName,
                photo: widget.photos[index],
              );

              return Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,

                  child: Hero(
                    tag: imageUrl,

                    child: CachedNetworkImage(
                      imageUrl: imageUrl,

                      fit: BoxFit.contain,

                      fadeInDuration: Duration.zero,

                      fadeOutDuration: Duration.zero,

                      progressIndicatorBuilder: (context, url, progress) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: progress.progress,
                          ),
                        );
                      },

                      errorWidget: (context, url, error) {
                        return const Center(
                          child: Text(
                            "Image Not Found",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // ====================================
          // LEFT ARROW
          // ====================================
          if (currentIndex > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,

              child: Center(
                child: Material(
                  color: Colors.transparent,

                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),

                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },

                    child: Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ====================================
          // RIGHT ARROW
          // ====================================
          if (currentIndex < widget.photos.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,

              child: Center(
                child: Material(
                  color: Colors.transparent,

                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),

                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },

                    child: Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ====================================
          // SELECTED INDICATOR
          // ====================================
          if (isSelected)
            Positioned(
              left: 20,
              bottom: 25,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.amber,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(Icons.check, color: Colors.black, size: 18),

                    SizedBox(width: 6),

                    Text(
                      "Selected",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
