import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint("Could not launch: $url");
      }
    } catch (e) {
      debugPrint("Launch Error: $e");
    }
  }

  Future<void> _callStudio() async {
    final Uri uri = Uri(scheme: 'tel', path: '7983139083');

    try {
      final bool launched = await launchUrl(uri);

      if (!launched) {
        debugPrint("Could not launch phone");
      }
    } catch (e) {
      debugPrint("Phone Launch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.white24, thickness: .5),

        const SizedBox(height: 25),

        const Text(
          "Need Help?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            _FooterButton(icon: Icons.call, title: "Call", onTap: _callStudio),

            _FooterButton(
              icon: Icons.language,
              title: "Website",
              onTap: () => _launch("https://www.picturepalaceproductions.com"),
            ),

            _FooterButton(
              icon: Icons.camera_alt,
              title: "Instagram",
              onTap: () =>
                  _launch("https://instagram.com/picturepalaceproductions"),
            ),

            _FooterButton(
              icon: Icons.play_circle_fill,
              title: "YouTube",
              onTap: () =>
                  _launch("https://youtube.com/@picturepalaceproductions"),
            ),
          ],
        ),

        const SizedBox(height: 30),

        const Text(
          "Version 1.0.0",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),

        const SizedBox(height: 10),

        const Text(
          "© Since 1950",
          style: TextStyle(
            color: AppColors.primaryGold,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "Picture Palace Productions",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FooterButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,

            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(.35),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),

            child: Icon(icon, color: Colors.black, size: 30),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
