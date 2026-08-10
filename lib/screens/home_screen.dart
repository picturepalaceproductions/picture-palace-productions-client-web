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

  Future<void> _openAlbum() async {
    FocusScope.of(context).unfocus();

    final enteredCode = albumCodeController.text.trim();

    if (enteredCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your Wedding Album Code")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final code = enteredCode.toUpperCase();

    debugPrint("Album Code = '$code'");

    final album = await _albumService.openAlbum(code);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (album == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Album Not Found")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DayScreen(album: album)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,

      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Mobile / tablet / desktop detection
          final bool isMobile = width < 600;
          final bool isSmallMobile = height < 750;

          // Main content width
          final double contentWidth = isMobile
              ? width.clamp(300.0, 430.0)
              : 430.0;

          // Responsive spacing
          final double topSpace = isMobile ? (isSmallMobile ? 8 : 14) : 28;

          final double logoScale = isMobile
              ? (isSmallMobile ? 0.72 : 0.82)
              : 0.90;

          final double betweenLogoAndCard = isMobile
              ? (isSmallMobile ? 8 : 14)
              : 20;

          return Stack(
            fit: StackFit.expand,
            children: [
              // =========================================================
              // BACKGROUND IMAGE
              // =========================================================
              Image.asset(
                "assets/images/background.jpg",
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),

              // Dark cinematic overlay
              Container(color: Colors.black.withValues(alpha: 0.72)),

              // =========================================================
              // MAIN CONTENT
              // =========================================================
              SafeArea(
                child: Center(
                  child: SizedBox(
                    width: contentWidth,

                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 20,
                      ),

                      child: Column(
                        children: [
                          SizedBox(height: topSpace),

                          // =================================================
                          // LOGO
                          // =================================================
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Transform.scale(
                                  scale: logoScale,
                                  child: const LogoWidget(),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: betweenLogoAndCard),

                          // =================================================
                          // ALBUM LOGIN CARD
                          // =================================================
                          Container(
                            width: double.infinity,

                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 20,
                              vertical: isMobile ? 14 : 18,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF151515,
                              ).withValues(alpha: 0.94),

                              borderRadius: BorderRadius.circular(
                                isMobile ? 18 : 22,
                              ),

                              border: Border.all(
                                color: AppColors.primaryGold,
                                width: 0.8,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),

                            child: Column(
                              children: [
                                Text(
                                  "ENTER YOUR WEDDING ALBUM CODE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: isMobile ? 1.3 : 1.8,
                                  ),
                                ),

                                SizedBox(height: isMobile ? 12 : 16),

                                CustomTextField(
                                  controller: albumCodeController,
                                  hintText: "PP2026-001",
                                  icon: Icons.photo_library_rounded,
                                ),

                                SizedBox(height: isMobile ? 12 : 16),

                                PrimaryButton(
                                  title: _isLoading
                                      ? "OPENING ALBUM..."
                                      : "OPEN ALBUM",

                                  onPressed: () {
                                    if (!_isLoading) {
                                      _openAlbum();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isMobile ? 10 : 14),

                          // =================================================
                          // WELCOME CARD
                          // =================================================
                          Container(
                            width: double.infinity,

                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 18,
                              vertical: isMobile ? 10 : 14,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF101010,
                              ).withValues(alpha: 0.94),

                              borderRadius: BorderRadius.circular(
                                isMobile ? 16 : 18,
                              ),

                              border: Border.all(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),

                            child: Column(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: AppColors.primaryGold,
                                  size: isMobile ? 23 : 28,
                                ),

                                SizedBox(height: isMobile ? 5 : 8),

                                Text(
                                  "Welcome to Your Wedding Gallery",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 14 : 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: isMobile ? 5 : 8),

                                Text(
                                  "Enter your Wedding Album Code to access your "
                                  "wedding gallery and select your favourite "
                                  "memories beautifully captured by Picture Palace Productions.",
                                  textAlign: TextAlign.center,
                                  maxLines: isMobile ? 3 : 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isMobile ? 10.5 : 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // =================================================
                          // FOOTER
                          // =================================================
                          Expanded(
                            flex: 4,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: const FooterWidget(),
                              ),
                            ),
                          ),

                          SizedBox(height: isMobile ? 4 : 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
