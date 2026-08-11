import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/album_service.dart';

import '../widgets/custom_textfield.dart';
import '../widgets/footer_widget.dart';
import '../widgets/logo_widget.dart';
import '../widgets/primary_button.dart';

import 'day_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController albumCodeController = TextEditingController();

  final AlbumService _albumService = const AlbumService();

  bool _isLoading = false;

  @override
  void dispose() {
    albumCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(.82)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final horizontalPadding = availableWidth < 390 ? 14.0 : 22.0;
                final contentWidth = (availableWidth - horizontalPadding * 2)
                    .clamp(0.0, 430.0);

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 25,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const LogoWidget(),
                          const SizedBox(height: 35),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF171717).withOpacity(.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primaryGold,
                                width: .8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold.withOpacity(.12),
                                  blurRadius: 40,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    "ENTER YOUR WEDDING ALBUM CODE",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                CustomTextField(
                                  controller: albumCodeController,
                                  hintText: "PP2026-001",
                                  icon: Icons.photo_library_rounded,
                                ),
                                const SizedBox(height: 28),
                                PrimaryButton(
                                  title: "OPEN ALBUM",
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    if (albumCodeController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter your Wedding Album Code",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    final album = await _albumService.openAlbum(
                                      albumCodeController.text.trim(),
                                    );
                                    if (!mounted) return;
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (album == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Album Not Found"),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DayScreen(album: album),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 28),
                                if (_isLoading)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 20),
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF101010),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: AppColors.primaryGold.withOpacity(.20),
                                    ),
                                  ),
                                  child: const Column(
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color: AppColors.primaryGold,
                                        size: 34,
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        "Welcome to Your Wedding Gallery",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Enter your Wedding Album Code to access your wedding gallery and select your favourite memories beautifully captured by Picture Palace Productions.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),
                          const FooterWidget(),
                          const SizedBox(height: 20),
                        ],
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
  }}
