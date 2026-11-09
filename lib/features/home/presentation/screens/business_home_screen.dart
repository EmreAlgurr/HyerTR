import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hyer/features/jobs/presentation/controllers/business_job_controller.dart';
import 'package:hyer/features/jobs/domain/models/job_model.dart';
import 'package:hyer/features/auth/presentation/controllers/auth_controller.dart';

class BusinessHomeScreen extends ConsumerWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myJobsAsync = ref.watch(myJobsProvider);
    final countsAsync = ref.watch(businessApplicationCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanlarım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: myJobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('Henüz iş ilanı oluşturmadınız.'));
          }
          final counts = countsAsync.value ?? {};

          return ListView.builder(
            itemCount: jobs.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final job = jobs[index];
              final jobCounts = counts[job.id] ?? {};

              return _JobCard(
                job: job,
                applicationCounts: jobCounts,
                onTap: () => context.go('/business/job/${job.id}/applicants'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/business/create-job'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final Map<String, int> applicationCounts;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.applicationCounts,
    required this.onTap,
  });

  int get _totalApplications =>
      applicationCounts.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + Arrow ──
              Row(
                children: [
                  Expanded(
                    child: Text(job.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 6),
              // ── Status + Type ──
              Row(
                children: [
                  _jobStatusBadge(job.status),
                  const SizedBox(width: 8),
                  if (job.jobType == JobType.volunteer)
                    _chip(Icons.volunteer_activism, 'Gönüllü',
                        Colors.green.shade700, Colors.green.shade50)
                  else
                    Text(
                        '₺${job.hourlyRate?.toStringAsFixed(0) ?? '-'} / saat',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                ],
              ),
              // ── Başvuru Durumları ──
              if (_totalApplications > 0) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _countChip(
                        Icons.people, '$_totalApplications Başvuru', Colors.blue),
                    if ((applicationCounts['pending'] ?? 0) > 0)
                      _countChip(Icons.hourglass_empty,
                          '${applicationCounts['pending']} Bekliyor', Colors.amber),
                    if ((applicationCounts['approved'] ?? 0) > 0)
                      _countChip(Icons.check, '${applicationCounts['approved']} Onaylı',
                          Colors.blue),
                    if ((applicationCounts['reviewing'] ?? 0) > 0)
                      _countChip(Icons.rate_review,
                          '${applicationCounts['reviewing']} İnceleniyor', Colors.orange),
                    if ((applicationCounts['completed'] ?? 0) > 0)
                      _countChip(Icons.check_circle,
                          '${applicationCounts['completed']} Tamamlandı', Colors.green),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text('Henüz başvuru yok',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobStatusBadge(JobStatus status) {
    final (Color color, String label) = switch (status) {
      JobStatus.open => (Colors.blue, 'Açık'),
      JobStatus.filled => (Colors.orange, 'Dolu'),
      JobStatus.completed => (Colors.green, 'Tamamlandı'),
      JobStatus.cancelled => (Colors.red, 'İptal'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _chip(IconData icon, String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
    );
  }

  Widget _countChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
