import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../models/user.dart' as app_user;

class SupabaseService {
  // Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase client instance
  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  // Initialize Supabase client
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey,
        debug: kDebugMode, // Enable debug mode only in debug builds
      );
      _client = Supabase.instance.client;
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Authentication methods
  // Mendaftar baru dengan email/password
  Future<AuthResponse> signUp({required String email, required String password}) async {
    try {
      // Validasi password strength
      _validatePassword(password);
      
      // Mendaftarkan user baru
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      
      return response;
    } catch (e) {
      debugPrint('Error in signUp: $e');
      rethrow;
    }
  }

  // Login dengan email/password
  Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      return response;
    } catch (e) {
      debugPrint('Error in signIn: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error in signOut: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: kIsWeb ? 'https://example.com/reset-callback' : null,
      );
    } catch (e) {
      debugPrint('Error in resetPassword: $e');
      rethrow;
    }
  }

  // Validasi password
  void _validatePassword(String password) {
    if (password.length < 6) {
      throw Exception('Password harus minimal 6 karakter');
    }

    // Tambahkan validasi lain seperti kombinasi karakter jika diperlukan
    // Contoh: harus memiliki angka, huruf besar, simbol, dll.
  }

  // Current user
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Convert Supabase User to App User
  app_user.User supabaseUserToAppUser(User user) {
    DateTime createDateTime = DateTime.now();
    
    // Handle createdAt properly, it could be a DateTime, String, or another format
    if (user.createdAt != null) {
      if (user.createdAt is DateTime) {
        createDateTime = user.createdAt as DateTime;
      } else if (user.createdAt is String) {
        try {
          createDateTime = DateTime.parse(user.createdAt as String);
        } catch (e) {
          // If parsing fails, use current time
          createDateTime = DateTime.now();
        }
      }
    }

    return app_user.User(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      createdAt: createDateTime,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? avatarUrl}) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      
      Map<String, dynamic> metadata = {};
      
      if (displayName != null) metadata['display_name'] = displayName;
      if (avatarUrl != null) metadata['avatar_url'] = avatarUrl;
      
      if (metadata.isNotEmpty) {
        await _client.auth.updateUser(UserAttributes(
          data: metadata,
        ));
      }
    } catch (e) {
      debugPrint('Error in updateUserProfile: $e');
      rethrow;
    }
  }

  // Goals CRUD operations
  Future<List<Map<String, dynamic>>> getGoals() async {
    try {
      if (currentUser == null) return [];
      
      final response = await _client
          .from('goals')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error in getGoals: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getGoal(String goalId) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      
      final response = await _client
          .from('goals')
          .select()
          .eq('id', goalId)
          .eq('user_id', currentUser!.id)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error in getGoal: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goalData) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      
      // Sanitasi data sebelum dikirim
      final sanitizedData = _sanitizeData(goalData);
      
      final response = await _client
          .from('goals')
          .insert(sanitizedData)
          .select()
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error in createGoal: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateGoal(String goalId, Map<String, dynamic> goalData) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      
      // Sanitasi data sebelum dikirim
      final sanitizedData = _sanitizeData(goalData);
      
      final response = await _client
          .from('goals')
          .update(sanitizedData)
          .eq('id', goalId)
          .eq('user_id', currentUser!.id)
          .select()
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error in updateGoal: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      
      await _client
          .from('goals')
          .delete()
          .eq('id', goalId)
          .eq('user_id', currentUser!.id);
    } catch (e) {
      debugPrint('Error in deleteGoal: $e');
      rethrow;
    }
  }

  // Transactions CRUD operations
  Future<List<Map<String, dynamic>>> getTransactions(String goalId) async {
    try {
      if (currentUser == null) return [];
      
      final response = await _client
          .from('transactions')
          .select()
          .eq('goal_id', goalId)
          .eq('user_id', currentUser!.id)
          .order('date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error in getTransactions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      
      // Sanitasi data sebelum dikirim
      final sanitizedData = _sanitizeData(transactionData);
      
      final response = await _client
          .from('transactions')
          .insert(sanitizedData)
          .select()
          .single();
      
      // Update goal current amount
      final goalId = sanitizedData['goal_id'];
      final goal = await getGoal(goalId);
      final currentAmount = goal['current_amount'] as double;
      final transactionAmount = sanitizedData['amount'] as double;
      
      await updateGoal(goalId, {
        'current_amount': currentAmount + transactionAmount,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      return response;
    } catch (e) {
      debugPrint('Error in createTransaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId, String goalId, double amount) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      
      await _client
          .from('transactions')
          .delete()
          .eq('id', transactionId)
          .eq('user_id', currentUser!.id);
      
      // Update goal current amount
      final goal = await getGoal(goalId);
      final currentAmount = goal['current_amount'] as double;
      
      await updateGoal(goalId, {
        'current_amount': currentAmount - amount,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error in deleteTransaction: $e');
      rethrow;
    }
  }
  
  // Sanitize data before sending to Supabase
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    // Make a copy to avoid modifying original
    final Map<String, dynamic> sanitized = Map.from(data);
    
    // Remove any null values
    sanitized.removeWhere((key, value) => value == null);
    
    // Sanitize string values to prevent XSS
    sanitized.forEach((key, value) {
      if (value is String) {
        // Basic XSS protection - removing script tags
        sanitized[key] = value.replaceAll(RegExp(r'<script.*?>.*?</script>', caseSensitive: false, multiLine: true), '');
      }
    });
    
    return sanitized;
  }
} 