import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/album_model.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatelessWidget {
  final AlbumModel album;
  final AlbumDay day;

  const CameraScreen({super.key, required this.album, required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: Column(
          children: [
            Text(
              album.clientName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              day.name,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Select Camera",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: day.folders.isEmpty
                  ? const Center(
                      child: Text(
                        "No Cameras Available",
                        style: TextStyle(color: Colors.white54, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: day.folders.length,

                      itemBuilder: (context, index) {
                        final folder = day.folders[index];

                        return Card(
                          color: const Color(0xFF181818),

                          margin: const EdgeInsets.only(bottom: 16),

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),

                            side: BorderSide(
                              color: AppColors.primaryGold.withOpacity(.35),
                            ),
                          ),

                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),

                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryGold,

                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                              ),
                            ),

                            title: Text(
                              folder.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),

                            subtitle: Text(
                              "${folder.count} Photos",
                              style: const TextStyle(color: Colors.white60),
                            ),

                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),

                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) => GalleryScreen(
                                    album: album,

                                    day: day,

                                    folder: folder,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
