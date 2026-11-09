import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyer/features/jobs/domain/models/application_model.dart';
import 'package:hyer/features/jobs/presentation/controllers/job_applicants_controller.dart';
import 'package:hyer/features/profile/presentation/screens/applicant_profile_screen.dart';
import 'package:intl/intl.dart';

class JobApplicantsScreen extends ConsumerWidget {
  final String jobId;

  const JobApplicantsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(jobApplicantsControllerProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başvurular'),
      ),
      body: applicantsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(child: Text('Henüz başvuru yok.'));
          }

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              final tasker = application.taskerProfile;
              
              // Profil bilgisi eksikse fallback
              final name = tasker?.fullName ?? 'İsimsiz Kullanıcı';
              final avatar = tasker?.avatarUrl;
              final date = DateFormat.yMMMd('tr').format(application.createdAt);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (tasker != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicantProfileScreen(profile: tasker),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil bilgisi bulunamadı.')),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Başvuran Bilgileri ──
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                              child: avatar == null ? const Icon(Icons.person) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Başvuru: $date', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              ),
                            ),
                            _buildStatusBadge(application.status),
                          ],
                        ),

                        // ── PENDING: Onay/Ret butonları ──
                        if (application.status == 'pending') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ref.read(jobApplicantsControllerProvider(jobId).notifier)
                                       .updateStatus(application.id, 'rejected');
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Reddet'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(jobApplicantsControllerProvider(jobId).notifier)
                                       .updateStatus(application.id, 'approved');
                                  },
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Onayla'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // ── REVIEWING: Fotoğraf kanıtı + Onay/Ret butonları ──
                        if (application.status == 'reviewing') ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Tasker işi tamamladığını bildirdi. Kanıt fotoğrafı:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          // ── Kanıt Fotoğrafı ──
                          if (application.proofUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 250,
                                ),
                                child: Image.network(
                                  application.proofUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 150,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400),
                                          const SizedBox(height: 4),
                                          Text('Fotoğraf yüklenemedi', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Fotoğraf yüklenmemiş', style: TextStyle(color: Colors.grey.shade500)),
                            ),
                          const SizedBox(height: 12),
                          // ── Onay / Ret Butonları ──
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showRejectConfirmation(context, ref, application);
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('❌ Reddet'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showApproveConfirmation(context, ref, application);
                                  },
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: const Text('✅ İşi Onayla'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // ── COMPLETED: Tamamlanmış iş ──
                        if (application.status == 'completed') ...[
                          const SizedBox(height: 12),
                          // Kanıt fotoğrafı varsa göster
                          if (application.proofUrl != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: Image.network(
                                  application.proofUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  '✅ Tamamlandı',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  // ── Durum Badge'i ──
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
        label = 'Bekliyor';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'Onaylandı';
        icon = Icons.check;
        break;
      case 'rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Reddedildi';
        icon = Icons.close;
        break;
      case 'reviewing':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'İnceleniyor';
        icon = Icons.rate_review;
        break;
      case 'completed':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Tamamlandı';
        icon = Icons.check_circle;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Onay Dialogu ──
  void _showApproveConfirmation(BuildContext context, WidgetRef ref, ApplicationModel application) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('İşi Onayla'),
            ],
          ),
          content: const Text(
            'Bu işi tamamlandı olarak onaylamak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(jobApplicantsControllerProvider(jobId).notifier)
                   .approveCompletion(application.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('İş başarıyla onaylandı! ✅'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  // ── Red Dialogu ──
  void _showRejectConfirmation(BuildContext context, WidgetRef ref, ApplicationModel application) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('İşi Reddet'),
            ],
          ),
          content: const Text(
            'Bu tamamlama kanıtını reddetmek istediğinize emin misiniz? Tasker tekrar fotoğraf yükleyebilecek.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(jobApplicantsControllerProvider(jobId).notifier)
                   .rejectCompletion(application.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tamamlama kanıtı reddedildi.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reddet'),
            ),
          ],
        );
      },
    );
  }
}
