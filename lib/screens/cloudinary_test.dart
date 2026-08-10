import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CloudinaryTest extends StatelessWidget {
  const CloudinaryTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Cloudinary Test"),
        backgroundColor: Colors.black,
      ),

      body: Center(
        child: CachedNetworkImage(

          imageUrl:
              "https://res.cloudinary.com/gs7boqwd/image/upload/v1786046091/IMG_3180_zathst.jpg",

          fit: BoxFit.contain,

          placeholder: (context, url) =>
              const CircularProgressIndicator(),

          errorWidget: (context, url, error) =>
              const Icon(
            Icons.error,
            color: Colors.red,
            size: 60,
          ),
        ),
      ),
    );
  }
}
