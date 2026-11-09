import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hyer/features/jobs/data/jobs_repository.dart';
import 'package:hyer/features/jobs/domain/models/application_model.dart';

part 'job_applicants_controller.g.dart';

@riverpod
class JobApplicantsController extends _$JobApplicantsController {
  
  @override
  Future<List<ApplicationModel>> build(String jobId) async {
    return ref.read(jobsRepositoryProvider).getApplicationsForJob(jobId);
  }

  Future<void> updateStatus(String applicationId, String status) async {
    // 1. Önce repository'de güncelle
    await ref.read(jobsRepositoryProvider).updateApplicationStatus(applicationId, status);
    
    // 2. Listeyi yenile (UI güncellensin)
    ref.invalidateSelf();
    await future;
  }

  // İşveren: İş kanıtını onayla (reviewing -> completed)
  Future<void> approveCompletion(String applicationId) async {
    await ref.read(jobsRepositoryProvider).approveJobCompletion(applicationId);
    ref.invalidateSelf();
    await future;
  }

  // İşveren: İş kanıtını reddet (reviewing -> approved)
  Future<void> rejectCompletion(String applicationId) async {
    await ref.read(jobsRepositoryProvider).rejectJobCompletion(applicationId);
    ref.invalidateSelf();
    await future;
  }
}
