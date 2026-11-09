import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:hyer/features/auth/presentation/screens/login_screen.dart';
import 'package:hyer/features/home/presentation/screens/tasker_home_screen.dart';
import 'package:hyer/features/home/presentation/screens/business_home_screen.dart';
import 'package:hyer/features/jobs/presentation/screens/create_job_screen.dart';
import 'package:hyer/features/jobs/presentation/screens/job_applicants_screen.dart';
import 'package:hyer/features/profile/presentation/screens/profile_screen.dart';
import 'package:hyer/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';
import 'package:hyer/routing/go_router_refresh_stream.dart';

// HomeScreen (Loading veya Yönlendirme Kontrolü)
// Kullanıcı '/home'a geldiğinde rolüne göre asıl sayfaya yönlendirilecek.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      body: roleAsync.when(
        data: (role) {
          // Rol bilgisi geldi, yönlendirme yap
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (role == 'business') {
              context.go('/business');
            } else if (role == 'tasker') {
              context.go('/tasker');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı rolü bulunamadı.')));
            }
          });
          return const Center(child: CircularProgressIndicator());
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(goRouterRefreshStreamProvider);
  
  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
       final session = Supabase.instance.client.auth.currentSession;
       final isLoggedIn = session != null;
       
       final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/onboarding';

       if (!isLoggedIn && !isLoggingIn) {
         return '/onboarding';
       }

       if (isLoggedIn && isLoggingIn) {
         return '/home';
       }

       return null; 
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginScreen(initialRole: role);
        },
      ),
      // Loading State (Ara Katman)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Ana Sayfalar (Bottom Navigation ile)
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
           GoRoute(
             path: '/tasker',
             builder: (context, state) => const TaskerHomeScreen(),
           ),
           GoRoute(
             path: '/business',
             builder: (context, state) => const BusinessHomeScreen(),
             routes: [
                 GoRoute(
                   path: 'create-job',
                   builder: (context, state) => const CreateJobScreen(),
                 ),
                 GoRoute(
                   path: 'job/:jobId/applicants',
                   builder: (context, state) => JobApplicantsScreen(jobId: state.pathParameters['jobId']!),
                 ),
             ],
           ),
           GoRoute(
             path: '/profile',
             builder: (context, state) => const ProfileScreen(),
           ),
        ],
      ),
    ],
  );
});

// Basit bir Bottom Navigation Bar Scaffold
class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mevcut path'i al
    final location = GoRouterState.of(context).uri.path;
    
    // Rolü kontrol et
    final roleAsync = ref.watch(userRoleProvider);
    final role = roleAsync.value;

    // Hangi index seçili olmalı?
    int currentIndex = 0;
    if (location.startsWith('/tasker')) currentIndex = 0;
    if (location.startsWith('/business')) currentIndex = 0; // Business ve Tasker ana ekranları ilk tab
    if (location.startsWith('/profile')) currentIndex = 1;

    return Scaffold(
      body: child,
      bottomNavigationBar: role == null ? null : NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            if (role == 'business') context.go('/business');
            else context.go('/tasker');
          } else if (index == 1) {
            context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
