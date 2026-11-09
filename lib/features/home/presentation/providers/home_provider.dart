import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';
import 'package:hyer/features/jobs/data/jobs_repository.dart';
import 'package:hyer/features/jobs/domain/models/job_model.dart';

final openJobsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final repository = ref.watch(jobsRepositoryProvider);
  return await repository.getOpenJobs();
});

// Tasker'ın tüm başvuru durumları (jobId -> status)
final myApplicationStatusesProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return {};
  final repository = ref.watch(jobsRepositoryProvider);
  return repository.getMyApplicationStatuses(user.id);
});
