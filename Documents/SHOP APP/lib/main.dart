import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage Cache
  await LocalStorageService.initialize();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Note: .env file not found or empty, using environment defaults.');
  }

  // Initialize Supabase Backend
  await SupabaseService.initialize();

  // Initialize Notifications & Firebase
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: TowelShopApp(),
    ),
  );
}

class TowelShopApp extends StatelessWidget {
  const TowelShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftTouch Towels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
