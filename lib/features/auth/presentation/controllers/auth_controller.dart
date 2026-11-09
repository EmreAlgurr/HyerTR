import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';

// Controller Provider
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is void (null)
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUpWithEmail(
        email: email,
        password: password,
        role: role,
      );
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
    required String requiredRole, // The role the user is trying to login as
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      
      // 1. Attempt Login
      final response = await repository.signInWithEmail(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // 2. Fetch Role from DB
        final dbRole = await repository.getUserRole(user.id);
        
        // 3. Verify Role
        if (dbRole != requiredRole) {
           // Mismatch: Sign out immediately
           await repository.signOut();
           
           // Throw informative error (Turkish)
           String roleName = requiredRole == 'business' ? 'İşveren' : 'Çalışan';
           String dbRoleName = dbRole == 'business' ? 'İşveren' : 'Çalışan';
           
           if (dbRole == null) {
             throw Exception("Kullanıcı profili bulunamadı.");
           }
           
           throw Exception("Bu hesap $dbRoleName hesabıdır. $roleName girişinden işlem yapamazsınız.");
        }
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    });
  }
}
