import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';

// Stream Provider for Auth State changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Provider to fetch user role asynchronously
final userRoleProvider = FutureProvider<String?>((ref) async {
  // Auth state'i dinle
  // NOT: StreamProvider'ın ilk değeri loading olabilir, veri gelmesini bekle
  final authState = ref.watch(authStateProvider);
  
  // Eğer henüz veri yoksa veya loading ise null dönme (loading state'de kalması daha iyi olabilir ama
  // authState.value?.session?.user kontrolü ile devam edelim)
  final user = authState.asData?.value.session?.user;
  
  // Eğer AuthState'den user gelmediyse, repository'den direkt okumayı dene (Refresh durumları için)
  final currentUser = user ?? ref.read(authRepositoryProvider).currentUser;
  
  if (currentUser == null) return null;
  
  final repository = ref.watch(authRepositoryProvider);
  return repository.getUserRole(currentUser.id);
});
