import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // Read from dart-define or default empty for offline
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('ℹ️ Supabase credentials not set. Running in Local Offline-First Mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      _client = Supabase.instance.client;
      debugPrint('✅ Supabase initialized successfully.');
    } catch (e) {
      debugPrint('⚠️ Supabase init error: $e. Falling back to Local SQLite.');
    }
  }

  static SupabaseClient? get client => _client;
  static bool get isConnected => _client != null && _client?.auth.currentSession != null;
}

