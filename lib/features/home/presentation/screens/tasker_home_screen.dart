import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:hyer/features/home/presentation/providers/home_provider.dart';
import 'package:hyer/features/jobs/domain/models/job_model.dart';
import 'package:hyer/features/jobs/presentation/controllers/job_detail_controller.dart';
import 'package:hyer/features/auth/presentation/controllers/auth_controller.dart';

class TaskerHomeScreen extends ConsumerWidget {
  const TaskerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(openJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Açık İşler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: jobsAsync.when(
        data: (jobs) => _TaskerBody(jobs: jobs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}

// ════════════════════════════════════════════
// Main Body: Split Layout (Panel + Map)
// ════════════════════════════════════════════
class _TaskerBody extends ConsumerStatefulWidget {
  final List<JobModel> jobs;
  const _TaskerBody({required this.jobs});

  @override
  ConsumerState<_TaskerBody> createState() => _TaskerBodyState();
}

class _TaskerBodyState extends ConsumerState<_TaskerBody> {
  late LatLng _initialCenter;
  final MapController _mapController = MapController();
  String? _selectedJobId;

  @override
  void initState() {
    super.initState();
    if (widget.jobs.isNotEmpty &&
        widget.jobs.first.latitude != null &&
        widget.jobs.first.longitude != null) {
      _initialCenter =
          LatLng(widget.jobs.first.latitude!, widget.jobs.first.longitude!);
    } else {
      _initialCenter = const LatLng(41.0082, 28.9784);
    }
  }

  void _selectJob(JobModel job) {
    setState(() => _selectedJobId = job.id);
    if (job.latitude != null && job.longitude != null) {
      _mapController.move(LatLng(job.latitude!, job.longitude!), 15.0);
    }
    _showJobDetails(context, job);
  }

  Color _markerColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.blue;
      case 'reviewing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusesAsync = ref.watch(myApplicationStatusesProvider);
    final statuses = statusesAsync.value ?? {};

    return Row(
      children: [
        // ── Sol Panel: İş Listesi ──
        SizedBox(
          width: 360,
          child: _buildJobPanel(statuses),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        // ── Sağ: Harita ──
        Expanded(child: _buildMap(statuses)),
      ],
    );
  }

  // ════════════════════════════════════════
  // Sol Panel
  // ════════════════════════════════════════
  Widget _buildJobPanel(Map<String, String> statuses) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(Icons.work_outline, size: 22, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                Text('İş İlanları',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.grey.shade800)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${widget.jobs.length}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 13)),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: widget.jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('İlan bulunamadı.',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.jobs.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final job = widget.jobs[index];
                      return _buildJobCard(
                          job, statuses[job.id], _selectedJobId == job.id);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobModel job, String? appStatus, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: isSelected ? 2 : 0.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectJob(job),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Status
                Row(children: [
                  Expanded(
                    child: Text(job.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (appStatus != null) ...[
                    const SizedBox(width: 8),
                    _statusBadge(appStatus),
                  ],
                ]),
                if (job.description != null &&
                    job.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(job.description!,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 10),
                // Date + Time + Price
                Row(children: [
                  Icon(Icons.calendar_today,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                      '${job.startTime.day}.${job.startTime.month}.${job.startTime.year}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                      '${job.startTime.hour.toString().padLeft(2, '0')}:${job.startTime.minute.toString().padLeft(2, '0')}-${job.endTime.hour.toString().padLeft(2, '0')}:${job.endTime.minute.toString().padLeft(2, '0')}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const Spacer(),
                  if (job.jobType == JobType.volunteer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Gönüllü',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600)),
                    )
                  else
                    Text('₺${job.hourlyRate?.toStringAsFixed(0) ?? '-'}/sa',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (Color bg, Color fg, String label) = switch (status) {
      'pending' => (Colors.amber.shade100, Colors.amber.shade900, 'Bekliyor'),
      'approved' =>
        (Colors.blue.shade100, Colors.blue.shade900, 'Onaylandı'),
      'reviewing' =>
        (Colors.orange.shade100, Colors.orange.shade900, 'İnceleniyor'),
      'completed' =>
        (Colors.green.shade100, Colors.green.shade900, 'Tamamlandı'),
      'rejected' =>
        (Colors.red.shade100, Colors.red.shade900, 'Reddedildi'),
      _ => (Colors.grey.shade100, Colors.grey.shade700, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // ════════════════════════════════════════
  // Harita
  // ════════════════════════════════════════
  Widget _buildMap(Map<String, String> statuses) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: _initialCenter, initialZoom: 12.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.hyer.app',
        ),
        MarkerLayer(
          markers: widget.jobs
              .where((j) => j.latitude != null && j.longitude != null)
              .map((job) => Marker(
                    point: LatLng(job.latitude!, job.longitude!),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _selectJob(job),
                      child: Icon(Icons.location_on,
                          color: _markerColor(statuses[job.id]), size: 40),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ════════════════════════════════════════
  // İş Detay Bottom Sheet
  // ════════════════════════════════════════
  void _showJobDetails(BuildContext context, JobModel job) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(job.description ?? 'Açıklama yok',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              if (job.jobType == JobType.volunteer)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.volunteer_activism,
                        size: 20, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text('Gönüllü İş',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ]),
                )
              else
                Row(children: [
                  const Icon(Icons.currency_lira, size: 20, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                      '${job.hourlyRate?.toStringAsFixed(2) ?? 'Belirtilmemiş'} / saat',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.access_time_filled,
                    size: 20, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                    '${job.startTime.day}.${job.startTime.month}.${job.startTime.year} • ${job.startTime.hour.toString().padLeft(2, '0')}:${job.startTime.minute.toString().padLeft(2, '0')} - ${job.endTime.hour.toString().padLeft(2, '0')}:${job.endTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[800], fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 8),
              if (job.addressText != null)
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(job.addressText!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              const SizedBox(height: 24),
              // ── Buton bölümü ──
              Consumer(builder: (context, ref, child) {
                final applicationState =
                    ref.watch(jobDetailControllerProvider(job.id));
                return SizedBox(
                  width: double.infinity,
                  child: applicationState.when(
                    data: (status) {
                      if (status == 'completed') {
                        return _infoBanner(Colors.green, Icons.check_circle,
                            'İş Tamamlandı');
                      }
                      if (status == 'reviewing') {
                        return _infoBanner(Colors.orange, Icons.hourglass_top,
                            '⏳ İşveren Onayı Bekleniyor');
                      }
                      if (status == 'approved') {
                        return FilledButton.icon(
                          onPressed: () =>
                              _showCompleteJobDialog(context, ref, job),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('📸 İşi Bitir ve Kanıtla'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      bool hasApplied = status != null;
                      String btnText = 'İlana Başvur';
                      Color? btnColor;
                      if (status == 'pending') {
                        btnText = 'Başvuruldu (Bekliyor)';
                        btnColor = Colors.grey;
                      } else if (status == 'rejected') {
                        btnText = 'Başvuru Reddedildi';
                        btnColor = Colors.red;
                      }
                      return FilledButton(
                        onPressed: hasApplied
                            ? null
                            : () async {
                                await ref
                                    .read(jobDetailControllerProvider(job.id)
                                        .notifier)
                                    .apply();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Başvurunuz alındı!')));
                                }
                              },
                        style: hasApplied
                            ? FilledButton.styleFrom(
                                backgroundColor: btnColor,
                                disabledBackgroundColor: btnColor,
                                disabledForegroundColor: Colors.white)
                            : null,
                        child: Text(btnText),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Hata: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _infoBanner(MaterialColor color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color.shade700, size: 22),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                color: color.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ]),
    );
  }

  // ════════════════════════════════════════
  // İş Tamamlama Dialog
  // ════════════════════════════════════════
  void _showCompleteJobDialog(
      BuildContext context, WidgetRef ref, JobModel job) {
    Uint8List? selectedBytes;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          Future<void> pickPhoto() async {
            try {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1200,
                  maxHeight: 1200,
                  imageQuality: 80);
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                if (ctx.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (ctx.mounted) {
                      setDialogState(() {
                        selectedBytes = bytes;
                        selectedFileName = picked.name;
                      });
                    }
                  });
                }
              }
            } catch (e) {
              debugPrint('ImagePicker hatası: $e');
            }
          }

          return AlertDialog(
            title: const Row(children: [
              Icon(Icons.camera_alt, color: Colors.orange),
              SizedBox(width: 8),
              Text('İşi Tamamla'),
            ]),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                        'İşinizi tamamladığınıza dair bir fotoğraf ekleyin.',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 16),
                    if (selectedBytes == null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: isUploading ? null : pickPhoto,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text('Fotoğraf Seç',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14)),
                                ]),
                          ),
                        ),
                      )
                    else ...[
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(selectedBytes!,
                              height: 200,
                              fit: BoxFit.cover,
                              gaplessPlayback: true),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: isUploading
                            ? null
                            : () => setDialogState(() {
                                  selectedBytes = null;
                                  selectedFileName = null;
                                }),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Fotoğrafı Kaldır'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.red),
                      ),
                    ],
                    if (isUploading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text('Yükleniyor...',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('İptal'),
              ),
              FilledButton.icon(
                onPressed: isUploading
                    ? null
                    : () async {
                        setDialogState(() => isUploading = true);
                        try {
                          await ref
                              .read(jobDetailControllerProvider(job.id)
                                  .notifier)
                              .completeJob(
                                  imageBytes: selectedBytes,
                                  fileName: selectedFileName);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('İş başarıyla gönderildi! 🎉'),
                                    backgroundColor: Colors.green));
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            setDialogState(() => isUploading = false);
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text('Hata: $e'),
                                backgroundColor: Colors.red));
                          }
                        }
                      },
                icon: const Icon(Icons.check),
                label: const Text('Onayla ve Gönder'),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          );
        });
      },
    );
  }
}
