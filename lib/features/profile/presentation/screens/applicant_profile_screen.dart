import 'package:flutter/material.dart';
import 'package:hyer/features/auth/domain/profile_model.dart';

class ApplicantProfileScreen extends StatelessWidget {
  final ProfileModel profile;

  const ApplicantProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aday Profili'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: profile.avatarUrl != null 
                  ? NetworkImage(profile.avatarUrl!) 
                  : null,
              child: profile.avatarUrl == null 
                  ? Text(
                      (profile.fullName?.isNotEmpty == true) 
                          ? profile.fullName![0].toUpperCase() 
                          : '?',
                      style: const TextStyle(fontSize: 48, color: Colors.grey),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            
            // İsim
            Text(
              profile.fullName ?? 'İsimsiz Kullanıcı',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Rol (Opsiyonel)
            Chip(
              label: Text(
                profile.role == 'tasker' ? 'Tasker' : 'İşveren',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blueGrey,
            ),
            
            const SizedBox(height: 32),
            
            // İletişim Bilgileri Kartı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: Text(profile.phoneNumber ?? 'Telefon eklenmemiş'),
                      subtitle: const Text('Telefon'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.blue),
                      title: Text(profile.bio ?? 'Biografi eklenmemiş'),
                      subtitle: const Text('Hakkında'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
