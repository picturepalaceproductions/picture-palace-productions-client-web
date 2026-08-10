import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: AppColors.primaryGold.withOpacity(.45),
          width: 1.3,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: TextField(
        controller: controller,

        textCapitalization: TextCapitalization.characters,

        cursorColor: AppColors.primaryGold,

        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: .5,
        ),

        decoration: InputDecoration(
          border: InputBorder.none,

          hintText: hintText,

          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 17,
          ),

          prefixIcon: Icon(
            icon,
            color: AppColors.primaryGold,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}