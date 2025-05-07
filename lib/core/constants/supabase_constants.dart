import 'package:flutter_dotenv/flutter_dotenv.dart';

// Supabase credentials loaded from .env file
// Create a .env file at root of project with:
// SUPABASE_URL=your_supabase_url
// SUPABASE_ANON_KEY=your_supabase_anon_key

class SupabaseConstants {
  // Getter untuk mengambil URL dari .env file
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env file');
    }
    return url;
  }
  
  // Getter untuk mengambil Anon Key dari .env file
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
    }
    return key;
  }
} 