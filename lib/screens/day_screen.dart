import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/album_model.dart';
import 'camera_screen.dart';
import 'selection_screen.dart';

class DayScreen extends StatelessWidget {
  final AlbumModel album;

  const DayScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),

      // ==========================================
      // APP BAR
      // ==========================================
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,

        // BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // CLIENT NAME
        title: Text(
          album.clientName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        // ==========================================
        // MY SELECTION
        // ==========================================
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: InkWell(
              borderRadius: BorderRadius.circular(20),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectionScreen(album: album),
                  ),
                );
              },

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),

                  const SizedBox(width: 6),

                  const Text(
                    "My Selection",
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ==========================================
      // BODY
      // ==========================================
      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ======================================
            // EVENT NAME
            // ======================================
            Text(
              album.event,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // ======================================
            // SELECT DAY
            // ======================================
            const Text(
              "Select Day",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ======================================
            // DAY LIST
            // ======================================
            Expanded(
              child: ListView.builder(
                itemCount: album.days.length,

                itemBuilder: (BuildContext context, int index) {
                  final day = album.days[index];

                  return Card(
                    color: const Color(0xFF181818),

                    elevation: 0,

                    margin: const EdgeInsets.only(bottom: 16),

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

                      // ==================================
                      // DAY NUMBER
                      // ==================================
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryGold,

                        child: Text(
                          "${index + 1}",

                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // ==================================
                      // DAY NAME
                      // ==================================
                      title: Text(
                        day.name,

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      // ==================================
                      // CAMERA COUNT
                      // ==================================
                      subtitle: Text(
                        "${day.folders.length} Camera(s)",

                        style: const TextStyle(color: Colors.white60),
                      ),

                      // ==================================
                      // ARROW
                      // ==================================
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),

                      // ==================================
                      // OPEN CAMERA SCREEN
                      // ==================================
                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                CameraScreen(album: album, day: day),
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
