import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/local/hive_service.dart';
import 'core/cloud/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await HiveService.init();

  // Initialize Supabase (optional - app works offline)
  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
    // App continues to work in offline mode
  }

  runApp(const ProviderScope(child: AuraWalkApp()));
}

class AuraWalkApp extends StatelessWidget {
  const AuraWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraWalk',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
