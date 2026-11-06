import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/address/models/address.dart';
import '../../features/admin/models/store_settings.dart';
import '../../features/auth/models/user_profile.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
    }
  }

  // ==========================================
  // 1. STORE SETTINGS (Live Status, Shop Name, PIN)
  // ==========================================
  static const String _keyStoreSettings = 'app_store_settings';

  Future<void> saveStoreSettings(StoreSettings settings) async {
    try {
      final jsonStr = jsonEncode(settings.toJson());
      await _prefs?.setString(_keyStoreSettings, jsonStr);
    } catch (e) {
      debugPrint('Error caching store settings: $e');
    }
  }

  StoreSettings? getStoreSettings() {
    try {
      final jsonStr = _prefs?.getString(_keyStoreSettings);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return StoreSettings.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error reading cached store settings: $e');
    }
    return null;
  }

  // ==========================================
  // 2. USER PROFILE (Customer & Admin Details)
  // ==========================================
  static const String _keyUserProfile = 'app_user_profile';

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final jsonStr = jsonEncode(profile.toJson());
      await _prefs?.setString(_keyUserProfile, jsonStr);
    } catch (e) {
      debugPrint('Error caching user profile: $e');
    }
  }

  UserProfile? getUserProfile() {
    try {
      final jsonStr = _prefs?.getString(_keyUserProfile);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserProfile.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error reading cached user profile: $e');
    }
    return null;
  }

  Future<void> clearUserProfile() async {
    try {
      await _prefs?.remove(_keyUserProfile);
    } catch (e) {
      debugPrint('Error clearing cached user profile: $e');
    }
  }

  // ==========================================
  // 3. SAVED ADDRESSES
  // ==========================================
  static const String _keyAddresses = 'app_saved_addresses';

  Future<void> saveAddresses(List<Address> addresses) async {
    try {
      final list = addresses.map((a) => a.toJson()).toList();
      await _prefs?.setString(_keyAddresses, jsonEncode(list));
    } catch (e) {
      debugPrint('Error caching addresses: $e');
    }
  }

  List<Address>? getAddresses() {
    try {
      final jsonStr = _prefs?.getString(_keyAddresses);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) => Address.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error reading cached addresses: $e');
    }
    return null;
  }
}
