import 'package:flutter/material.dart';

enum JobStatus { open, filled, completed, cancelled }
enum JobType { paid, volunteer }

class JobModel {
  final String id;
  final String businessId;
  final String title;
  final String? description;
  final double? hourlyRate;
  final double? latitude;
  final double? longitude;
  final String? addressText;
  final String? businessName; // View'dan gelen şirket adı
  final DateTime startTime;
  final DateTime endTime;
  final JobStatus status;
  final JobType jobType;

  JobModel({
    required this.id,
    required this.businessId,
    required this.title,
    this.description,
    this.hourlyRate,
    this.latitude,
    this.longitude,
    this.addressText,
    this.businessName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.jobType = JobType.paid,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // View (available_jobs) artık 'lat' ve 'lng' kolonlarını hazır veriyor.
    // Karmaşık parsing işlemlerine gerek yok.
    
    return JobModel(
      id: json['id'].toString(), // BigInt gelebilir, String'e çevir
      businessId: json['business_id'],
      title: json['title'],
      description: json['description'],
      hourlyRate: json['hourly_rate'] != null ? (json['hourly_rate'] as num).toDouble() : null,
      latitude: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      longitude: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      addressText: json['address_text'],
      businessName: json['business_name'], // View'dan gelir
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: JobStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => JobStatus.open),
      // Mevcut kayıtlar 'job_type' içermeyebilir, varsayılan: paid
      jobType: JobType.values.firstWhere(
        (e) => e.name == json['job_type'],
        orElse: () => JobType.paid,
      ),
    );
  }
}
