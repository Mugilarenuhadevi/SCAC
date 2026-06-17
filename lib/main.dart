import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/voice_alert_service.dart';

bool _isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase auto-initialization failed: $e');
    debugPrint('Falling back to Mock Data for this session.');
  }
  
  try {
    await VoiceAlertService.init();
  } catch (e) {
    debugPrint('Voice service initialization failed: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: AirQualityApp()));
}

class AirQualityApp extends StatelessWidget {
  const AirQualityApp({super.key});

  static bool get isFirebaseReady => _isFirebaseInitialized;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Air Quality Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
