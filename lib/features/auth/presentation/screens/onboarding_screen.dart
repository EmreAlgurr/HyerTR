import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onRoleSelected(BuildContext context, String role) {
    debugPrint('Selected Role: $role');
    // Login rotası henüz query parameters kabul edecek şekilde ayarlanmadı ama
    // ileride seçilen rolü aktarmak için state management veya query param kullanacağız.
    context.go(Uri(path: '/login', queryParameters: {'role': role}).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _RoleCard(
                title: 'İş Arıyorum',
                subtitle: 'Tasker olarak para kazan',
                icon: Icons.work_outline_rounded,
                color: Theme.of(context).colorScheme.primaryContainer,
                onTap: () => _onRoleSelected(context, 'tasker'),
              ),
            ),
            Expanded(
              child: _RoleCard(
                title: 'Eleman Arıyorum',
                subtitle: 'Business olarak işini büyüt',
                icon: Icons.store_mall_directory_rounded,
                color: Theme.of(context).colorScheme.secondaryContainer,
                onTap: () => _onRoleSelected(context, 'business'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black87),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
