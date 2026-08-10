import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/selection_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // Load Previous Photo Selections
  // ==========================================

  await SelectionService.instance.loadSelections();

  runApp(const PicturePalaceProductionsClient());
}

class PicturePalaceProductionsClient extends StatelessWidget {
  const PicturePalaceProductionsClient({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Picture Palace Productions',

      theme: AppTheme.lightTheme,

      home: const HomeScreen(),
    );
  }
}
