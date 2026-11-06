import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/supabase_service.dart';
import '../models/user_profile.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final UserProfile? profile;
  final bool isInitialized;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.profile,
    this.isInitialized = false,
  });

  bool get isAuthenticated => user != null || profile != null;
  bool get isAdmin => profile?.isAdmin ?? false;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    UserProfile? profile,
    bool? isInitialized,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: clearUser ? null : (user ?? this.user),
      profile: clearUser ? null : (profile ?? this.profile),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService)
      : super(
          AuthState(
            profile: LocalStorageService().getUserProfile(),
            isInitialized: LocalStorageService().getUserProfile() != null,
          ),
        ) {
    _initializeAuth();
  }

  void _initializeAuth() {
    final client = _supabaseService.client;
    if (client != null) {
      // Listen to Supabase Auth State changes
      client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null) {
          await _loadProfile(session.user.id, session.user.email ?? '');
        } else {
          // If no remote session, clear user if not in demo mode
          if (state.profile?.id.startsWith('demo-') != true) {
            await LocalStorageService().clearUserProfile();
            state = state.copyWith(clearUser: true, isInitialized: true);
          }
        }
      });

      // Check current session
      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        _loadProfile(currentUser.id, currentUser.email ?? '');
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } else {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<void> _loadProfile(String userId, String email) async {
    try {
      final profileMap = await _supabaseService.fetchProfile(userId);
      final isAdminEmail = email.toLowerCase().trim() == 'kritikkhodiyar45@gmail.com';

      if (profileMap != null) {
        var profile = UserProfile.fromJson(profileMap);
        if (isAdminEmail && profile.role != 'admin') {
          profile = profile.copyWith(role: 'admin');
        }
        await LocalStorageService().saveUserProfile(profile);
        state = state.copyWith(
          user: _supabaseService.currentUser,
          profile: profile,
          isInitialized: true,
        );

        // Sync FCM token if available
        final fcm = NotificationService().fcmToken;
        if (fcm != null && fcm != profile.fcmToken) {
          await _supabaseService.updateProfile(userId: userId, fcmToken: fcm);
        }
      } else {
        // Fallback profile preserving any existing cached details
        final cached = LocalStorageService().getUserProfile();
        final fallbackProfile = UserProfile(
          id: userId,
          email: email,
          name: cached?.name.isNotEmpty == true
              ? cached!.name
              : (email.contains('@') ? email.split('@').first : 'Customer'),
          phone: cached?.phone ?? '',
          role: isAdminEmail ? 'admin' : 'customer',
        );
        await LocalStorageService().saveUserProfile(fallbackProfile);
        state = state.copyWith(
          user: _supabaseService.currentUser,
          profile: fallbackProfile,
          isInitialized: true,
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (SupabaseService.isConfigured) {
        final res = await _supabaseService.signInWithEmail(
          email: email,
          password: password,
        );
        if (res?.user != null) {
          await _loadProfile(res!.user!.id, res.user!.email ?? email);
          state = state.copyWith(isLoading: false);
          return true;
        }
      } else {
        // DEMO LOGIN (when Supabase URL/key has not been configured in .env yet)
        await Future.delayed(const Duration(milliseconds: 600));
        final isAdminEmail = email.toLowerCase().trim() == 'kritikkhodiyar45@gmail.com';
        final demoProfile = UserProfile(
          id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: isAdminEmail ? 'Kritik Khodiyar (Admin)' : 'Customer',
          phone: '+91 98765 43210',
          role: isAdminEmail ? 'admin' : 'customer',
        );
        state = state.copyWith(
          isLoading: false,
          profile: demoProfile,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (SupabaseService.isConfigured) {
        final res = await _supabaseService.signUpWithEmail(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );
        if (res?.user != null) {
          final registeredProfile = UserProfile(
            id: res!.user!.id,
            email: email.trim(),
            name: name.trim(),
            phone: phone.trim(),
            role: 'customer',
          );
          await LocalStorageService().saveUserProfile(registeredProfile);
          await _loadProfile(res.user!.id, email);
          state = state.copyWith(isLoading: false, profile: registeredProfile);
          return true;
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        final demoProfile = UserProfile(
          id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          phone: phone,
          role: 'customer',
        );
        await LocalStorageService().saveUserProfile(demoProfile);
        state = state.copyWith(
          isLoading: false,
          profile: demoProfile,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> updateCustomerProfile({
    required String name,
    required String phone,
  }) async {
    final current = state.profile;
    if (current == null) return false;

    final updated = current.copyWith(
      name: name.trim(),
      phone: phone.trim(),
    );

    state = state.copyWith(profile: updated);
    await LocalStorageService().saveUserProfile(updated);

    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        await client.from('profiles').upsert(updated.toJson());
        return true;
      } catch (e) {
        debugPrint('Error syncing profile update to Supabase: $e');
        return true;
      }
    }
    return true;
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
    await LocalStorageService().clearUserProfile();
    state = const AuthState(isInitialized: true);
  }

  void updateLocalProfile(UserProfile updated) async {
    await LocalStorageService().saveUserProfile(updated);
    state = state.copyWith(profile: updated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(SupabaseService());
});
