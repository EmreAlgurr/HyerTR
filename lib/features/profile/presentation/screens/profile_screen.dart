import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hyer/features/profile/presentation/controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(profileControllerProvider.notifier).updateProfile(
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      bio: _bioController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);

    // Initial data loading
    ref.listen(profileControllerProvider, (prev, next) {
      next.whenData((profile) {
        if (profile != null && !_isInit) {
          _nameController.text = profile.fullName ?? '';
          _phoneController.text = profile.phoneNumber ?? '';
          _bioController.text = profile.bio ?? '';
          _isInit = true; // Sadece ilk yüklemede doldur, kullanıcı düzenlerken bozma
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (!_isInit && profile != null) {
            // Hot reload vs. durumlarında veya ilk build anında da veriyi set edelim
             WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted && !_isInit) {
                    _nameController.text = profile.fullName ?? '';
                    _phoneController.text = profile.phoneNumber ?? '';
                    _bioController.text = profile.bio ?? '';
                    _isInit = true;
                    setState(() {});
                 }
             });
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                   CircleAvatar(
                     radius: 50,
                     backgroundColor: Colors.grey[200],
                     backgroundImage: profile?.avatarUrl != null 
                        ? NetworkImage(profile!.avatarUrl!) 
                        : null,
                     child: profile?.avatarUrl == null 
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                   ),
                   const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefon Numarası',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Hakkında / Biyografi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: profileAsync.isLoading ? null : _save,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                      child: profileAsync.isLoading 
                         ? const CircularProgressIndicator(color: Colors.white)
                         : const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}
