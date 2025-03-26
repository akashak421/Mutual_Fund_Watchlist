import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: '+91$phoneNumber',
        shouldCreateUser: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: '+91$phoneNumber',
        token: otp,
        type: OtpType.sms,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  bool get isAuthenticated => _supabase.auth.currentUser != null;
  
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
} 