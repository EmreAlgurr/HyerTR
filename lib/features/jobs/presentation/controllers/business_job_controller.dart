import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';
import 'package:hyer/features/jobs/data/jobs_repository.dart';
import 'package:hyer/features/jobs/domain/models/job_model.dart';
import 'package:hyer/features/home/presentation/providers/home_provider.dart';

// Kullanıcının (Business) kendi ilanlarını listeler
final myJobsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final repository = ref.watch(jobsRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return [];
  
  try {
    return await repository.getMyJobs(user.id);
  } catch (e, st) {
    debugPrint('Job Fetch Error: $e\n$st');
    // Hatanın aslını fırlatalım ki görelim
    throw Exception('İlanlar getirilemedi: $e');
  }
});

// Job Creation Controller
final businessJobControllerProvider = AsyncNotifierProvider<BusinessJobController, void>(() {
  return BusinessJobController();
});

class BusinessJobController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state
  }

  Future<void> createJob(JobModel job) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(jobsRepositoryProvider);
      await repository.createJob(job);
      
      // Başarılı
      state = const AsyncValue.data(null);
      // Hem kendi ilanlarımı hem de genel haritayı yenile
      ref.invalidate(myJobsProvider);
      ref.invalidate(openJobsProvider); // Tasker haritası için refresh
      // Eğer HomeProvider gibi başka ortak providerlar varsa onları da ekle
    } catch (e, st) {
      // Hata durumunda state'i güncelle ama hatayı da fırlat ki UI bilsin
      state = AsyncValue.error(e, st);
      // Hatanın detayını logla
      debugPrint('Create Job Failed: $e');
      
      if (e is PostgrestException) {
         throw Exception('Veritabanı hatası: ${e.message}\n(Code: ${e.code}, Details: ${e.details})');
      }
      throw Exception('İlan oluşturulamadı: $e');
    }
  }
}

// İşverenin tüm ilanlarındaki başvuru durum sayıları
final businessApplicationCountsProvider = FutureProvider.autoDispose<Map<String, Map<String, int>>>((ref) async {
  final jobs = await ref.watch(myJobsProvider.future);
  if (jobs.isEmpty) return {};
  
  final jobIds = jobs.map((j) => j.id).toList();
  final repository = ref.watch(jobsRepositoryProvider);
  return repository.getApplicationCountsForJobs(jobIds);
});
