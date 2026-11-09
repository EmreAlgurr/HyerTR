import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/features/auth/domain/profile_model.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Get current user session
  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign Up with Email and Password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String role, // 'business' or 'tasker'
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'role': role}, // Sending role as metadata
    );
  }

  // Sign In with Email and Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get User Role
  Future<String?> getUserRole(String userId) async {
    // 1. Try to get from 'profiles' table
    final response = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle(); 
    
    if (response != null && response['role'] != null) {
      return response['role'] as String;
    }

    // 2. Fallback: Check user_metadata if the user is the current user
    // This handles cases where the Supabase Trigger hasn't fired yet or failed.
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null && currentUser.id == userId) {
      return currentUser.userMetadata?['role'] as String?;
    }

    return null;
  }

  // Update Profile
  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? phoneNumber,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu yok.');

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;

    if (updates.isEmpty) return;

    await _supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.id);
  }

  // Get Current Profile
  Future<ProfileModel?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }
}
