import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ============================================================
        // PICTURE PALACE LOGO
        // ============================================================
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.12),
                blurRadius: 45,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Image.asset(
            'assets/logo/logo.png',
            width: 190,
            height: 190,
            fit: BoxFit.contain,

            // If the asset cannot be loaded, don't crash the page.
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Picture Palace logo could not be loaded: $error');

              return Container(
                width: 190,
                height: 190,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primaryGold,
                  size: 70,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 22),

        // ============================================================
        // BRAND NAME
        // ============================================================
        const Text(
          'Picture Palace',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Productions',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 14),

        // ============================================================
        // TAGLINE
        // ============================================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.35),
            ),
          ),
          child: const Text(
            'Memories Treasured Since 1950',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
