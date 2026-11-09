import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';
import 'package:hyer/features/auth/domain/profile_model.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  
  @override
  Future<ProfileModel?> build() async {
    return ref.read(authRepositoryProvider).getCurrentProfile();
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateProfile(
        fullName: fullName,
        bio: bio,
        phoneNumber: phoneNumber,
      );
      
      // Güncel datayı tekrar çekip state'e ver
      return await ref.read(authRepositoryProvider).getCurrentProfile();
    });
  }
}
