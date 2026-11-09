import 'package:hyer/features/auth/domain/profile_model.dart';

class ApplicationModel {
  final String id; // bigint as string
  final String jobId; // bigint as string
  final String taskerId;
  final String status;
  final DateTime createdAt;
  final ProfileModel? taskerProfile;
  final String? proofUrl;
  final DateTime? completedAt;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.taskerId,
    required this.status,
    required this.createdAt,
    this.taskerProfile,
    this.proofUrl,
    this.completedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      jobId: json['job_id'].toString(),
      taskerId: json['tasker_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      // Supabase join ile 'profiles' tablosu tekil obje olarak gelebilir
      // Eğer join yapmazsak bu null olabilir.
      taskerProfile: json['profiles'] != null 
          ? ProfileModel.fromJson(json['profiles']) 
          : null,
      proofUrl: json['proof_url'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }
}

