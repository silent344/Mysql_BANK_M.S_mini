import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static bool _isInitialized = false;
  static bool get isConfigured {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    return url.isNotEmpty &&
        key.isNotEmpty &&
        !url.contains('placeholder') &&
        !key.contains('placeholder');
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (isConfigured) {
      try {
        await Supabase.initialize(
          url: url,
          // ignore: deprecated_member_use
          anonKey: anonKey,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        );
        _isInitialized = true;
        debugPrint('✅ Supabase initialized successfully');
      } catch (e) {
        debugPrint('⚠️ Supabase init failed: $e');
      }
    } else {
      debugPrint('ℹ️ Supabase running in DEMO / PREVIEW mode (configure .env with real credentials)');
    }
  }

  SupabaseClient? get client {
    if (_isInitialized && isConfigured) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  User? get currentUser => client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final cli = client;
    if (cli == null) {
      throw Exception('Supabase client not initialized. Check .env configuration.');
    }

    final res = await cli.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'phone': phone?.trim() ?? '',
        'role': 'customer',
      },
    );

    // If user created, ensure profile record is synced
    if (res.user != null) {
      try {
        await cli.from('profiles').upsert({
          'id': res.user!.id,
          'email': email.trim(),
          'name': name.trim(),
          'phone': phone?.trim() ?? '',
          'role': 'customer',
        });
      } catch (e) {
        debugPrint('Profile upsert note: $e');
      }
    }

    return res;
  }

  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cli = client;
    if (cli == null) {
      throw Exception('Supabase client not initialized. Check .env configuration.');
    }

    return await cli.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInWithPhoneOtp({required String phone}) async {
    final cli = client;
    if (cli == null) throw Exception('Supabase not configured');
    await cli.auth.signInWithOtp(phone: phone.trim());
  }

  Future<AuthResponse?> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final cli = client;
    if (cli == null) throw Exception('Supabase not configured');
    return await cli.auth.verifyOTP(
      phone: phone.trim(),
      token: token.trim(),
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    final cli = client;
    if (cli != null) {
      await cli.auth.signOut();
    }
  }

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final cli = client;
    if (cli == null) return null;

    try {
      final res = await cli
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? fcmToken,
  }) async {
    final cli = client;
    if (cli == null) return;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (name != null) updates['name'] = name.trim();
    if (phone != null) updates['phone'] = phone.trim();
    if (fcmToken != null) updates['fcm_token'] = fcmToken;

    await cli.from('profiles').update(updates).eq('id', userId);
  }
}
