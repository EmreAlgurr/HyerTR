import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/core/theme/app_theme.dart';
import 'package:hyer/routing/app_router.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('tr');

  // TODO: Replace with your actual Supabase details
  await Supabase.initialize(
    url: 'https://flysxkafmxedenvndyue.supabase.co',
    anonKey: 'sb_publishable_6msFUz8RmHF_A5HnYUEXuQ_Ql11JY4-',
  );

  runApp(const ProviderScope(child: HyerApp()));
}

class HyerApp extends ConsumerWidget {
  const HyerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: 'HyerTR',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
