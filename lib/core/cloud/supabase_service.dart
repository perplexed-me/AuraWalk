import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Handles Supabase initialization and sync logic
class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('SupabaseService not initialized. Call init() first.');
    }
    return _client!;
  }

  // Initialize Supabase
  static Future<void> init() async {
    await dotenv.load();

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase URL or Anon Key not found in .env file');
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    _client = Supabase.instance.client;
  }

  // User authentication methods
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // Data sync methods
  static Future<void> syncSoundData(Map<String, dynamic> soundData) async {
    if (currentUser == null) return;

    await client.from('sound_data').insert({
      'user_id': currentUser!.id,
      'data': soundData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> syncWeatherData(Map<String, dynamic> weatherData) async {
    if (currentUser == null) return;

    await client.from('weather_data').insert({
      'user_id': currentUser!.id,
      'data': weatherData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> syncAuraData(Map<String, dynamic> auraData) async {
    if (currentUser == null) return;

    await client.from('aura_data').insert({
      'user_id': currentUser!.id,
      'data': auraData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Fetch user's data
  static Future<List<Map<String, dynamic>>> getUserSoundData() async {
    if (currentUser == null) return [];

    final response = await client
        .from('sound_data')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getUserWeatherData() async {
    if (currentUser == null) return [];

    final response = await client
        .from('weather_data')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getUserAuraData() async {
    if (currentUser == null) return [];

    final response = await client
        .from('aura_data')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
