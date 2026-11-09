import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/features/jobs/domain/models/job_model.dart';
import 'package:hyer/features/jobs/domain/models/application_model.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository(Supabase.instance.client);
});

class JobsRepository {
  final SupabaseClient _supabase;

  JobsRepository(this._supabase);

  Future<List<JobModel>> getOpenJobs() async {
    // 1. READ: 'available_jobs' View'ından oku (lat/lng, business name hazır gelir)
    final data = await _supabase
        .from('available_jobs')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => JobModel.fromJson(e)).toList();
  }

  // İşverenin kendi ilanlarını getir
  Future<List<JobModel>> getMyJobs(String userId) async {
    // Kendi ilanlarını da View'dan çekebiliriz (tutarlılık için)
    final data = await _supabase
        .from('available_jobs')
        .select()
        .eq('business_id', userId)
        .order('created_at', ascending: false);
        
    return (data as List).map((e) => JobModel.fromJson(e)).toList();
  }

  // Yeni iş ilanı oluştur
  Future<void> createJob(JobModel job) async {
    // 2. WRITE: 'jobs' tablosuna yaz
    // Location: PostGIS st_point(lon, lat) fonksiyonu ile gönder
    await _supabase.from('jobs').insert({
      'business_id': job.businessId,
      'title': job.title,
      'description': job.description,
      'hourly_rate': job.hourlyRate,
      'job_type': job.jobType.name, // 'paid' veya 'volunteer'
      // WKT (Well-Known Text) Formatı: POINT(longitude latitude)
      // Supabase/Postgres string'i otomatik olarak geometry tipine cast eder.
      'location': 'POINT(${job.longitude} ${job.latitude})', 
      'address_text': job.addressText,
      'start_time': job.startTime.toIso8601String(),
      'end_time': job.endTime.toIso8601String(),
      'status': job.status.name,
    });
  }
  // İş İlanına Başvur
  Future<void> applyToJob(String jobId, String taskerId) async {
    // jobId veritabanında BIGINT, ama biz String gönderiyoruz. Supabase bunu handle eder 
    // veya int.parse(jobId) yapmamız gerekebilir.
    // DİKKAT: Veritabanında application.job_id -> BIGINT
    await _supabase.from('applications').insert({
      'job_id': int.parse(jobId), // String -> int dönüşümü
      'tasker_id': taskerId,
      'status': 'pending',
    });
  }


  // Başvuru Durumunu Getir
  Future<String?> getApplicationStatus(String jobId, String taskerId) async {
    final data = await _supabase
        .from('applications')
        .select('status')
        .eq('job_id', int.parse(jobId))
        .eq('tasker_id', taskerId)
        .maybeSingle(); 
    
    return data?['status'] as String?;
  }

  // İş İlanına Gelen Başvuruları Getir
  Future<List<ApplicationModel>> getApplicationsForJob(String jobId) async {
    final data = await _supabase
        .from('applications')
        .select('*, profiles(*)') // profiles tablosunu join'le
        .eq('job_id', int.parse(jobId))
        .order('created_at', ascending: false);


    return (data as List).map((e) => ApplicationModel.fromJson(e)).toList();
  }

  // Başvuru Durumunu Güncelle
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _supabase
        .from('applications')
        .update({'status': status})
        .eq('id', int.parse(applicationId)); // id BIGINT varsayıldı
  }

  // ── Tasker'ın belirli bir iş için kendi başvuru ID'sini getir ──
  Future<String?> getMyApplicationId(String jobId, String taskerId) async {
    final data = await _supabase
        .from('applications')
        .select('id')
        .eq('job_id', int.parse(jobId))
        .eq('tasker_id', taskerId)
        .maybeSingle();

    return data?['id']?.toString();
  }

  // ── İşi Tamamla (Fotoğraf kanıtı ile) ──
  Future<void> completeJob({
    required String applicationId,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    String? proofUrl;

    // 1. Fotoğraf varsa Supabase Storage'a yükle
    if (imageBytes != null && fileName != null) {
      final filePath = 'proofs/$applicationId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      try {
        await _supabase.storage
            .from('job_proofs')
            .uploadBinary(
              filePath,
              imageBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
      } catch (e) {
        throw Exception('Fotoğraf yüklenemedi (Storage hatası): $e\n'
            'Bucket "job_proofs" var mı ve public mı kontrol edin.');
      }
      
      // Public URL'yi al
      proofUrl = _supabase.storage
          .from('job_proofs')
          .getPublicUrl(filePath);
    }

    // 2. applications tablosunu güncelle (reviewing: işveren onayı bekleniyor)
    try {
      await _supabase
          .from('applications')
          .update({
            'status': 'reviewing',
            'proof_url': proofUrl,
            'completed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', int.parse(applicationId));
    } catch (e) {
      throw Exception('Veritabanı güncellenemedi: $e\n'
          '"proof_url" kolonu var mı kontrol edin.');
    }
  }

  // ── İşveren: İş Tamamlamayı Onayla ──
  Future<void> approveJobCompletion(String applicationId) async {
    await _supabase
        .from('applications')
        .update({
          'status': 'completed',
        })
        .eq('id', int.parse(applicationId));
  }

  // ── İşveren: İş Tamamlamayı Reddet ──
  Future<void> rejectJobCompletion(String applicationId) async {
    await _supabase
        .from('applications')
        .update({
          'status': 'approved',
          'proof_url': null,
          'completed_at': null,
        })
        .eq('id', int.parse(applicationId));
  }

  // ── Tasker'ın tüm başvuru durumlarını getir (Panel badge'leri için) ──
  Future<Map<String, String>> getMyApplicationStatuses(String taskerId) async {
    final data = await _supabase
        .from('applications')
        .select('job_id, status')
        .eq('tasker_id', taskerId);

    final map = <String, String>{};
    for (final row in data) {
      map[row['job_id'].toString()] = row['status'];
    }
    return map;
  }

  // ── İşverenin ilanlarına gelen başvuru durum sayıları ──
  Future<Map<String, Map<String, int>>> getApplicationCountsForJobs(List<String> jobIds) async {
    if (jobIds.isEmpty) return {};
    final intIds = jobIds.map((id) => int.parse(id)).toList();
    final data = await _supabase
        .from('applications')
        .select('job_id, status')
        .inFilter('job_id', intIds);

    final counts = <String, Map<String, int>>{};
    for (final row in data) {
      final jobId = row['job_id'].toString();
      final status = row['status'] as String;
      counts.putIfAbsent(jobId, () => {});
      counts[jobId]![status] = (counts[jobId]![status] ?? 0) + 1;
    }
    return counts;
  }
}
