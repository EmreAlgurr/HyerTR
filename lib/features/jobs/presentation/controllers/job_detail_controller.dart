import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';
import 'package:hyer/features/jobs/data/jobs_repository.dart';

part 'job_detail_controller.g.dart';

@riverpod
class JobDetailController extends _$JobDetailController {
  
  @override
  Future<String?> build(String jobId) async {
    // Giriş yapmış kullanıcıyı al
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return null;

    // Repository'den başvuru durumunu sorgula (String? döner: 'pending', 'approved', 'rejected' veya null)
    return ref.read(jobsRepositoryProvider).getApplicationStatus(jobId, user.id);
  }

  // Başvuru İşlemi
  Future<void> apply() async {
    // State'i loading'e çek
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception("Kullanıcı bulunamadı");

      // 'jobId' parametresi build metodundan otomatik olarak sınıf içinde erişilebilir (this.jobId olarak)
      await ref.read(jobsRepositoryProvider).applyToJob(jobId, user.id);
      
      // Başarılı olursa 'pending' dön
      return 'pending';
    });
  }

  // İşi Tamamla (Fotoğraf kanıtı ile)
  Future<void> completeJob({Uint8List? imageBytes, String? fileName}) async {
    state = const AsyncValue.loading();

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception("Kullanıcı bulunamadı");

      final repository = ref.read(jobsRepositoryProvider);

      // Önce application ID'yi bul
      final applicationId = await repository.getMyApplicationId(jobId, user.id);
      if (applicationId == null) throw Exception("Başvuru bulunamadı");

      // Repository'ye gönder
      await repository.completeJob(
        applicationId: applicationId,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      state = const AsyncValue.data('reviewing');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Dialog'un catch bloğuna düşsün
    }
  }
}

