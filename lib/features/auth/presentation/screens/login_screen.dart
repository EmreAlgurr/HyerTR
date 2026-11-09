import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hyer/features/auth/presentation/controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialRole;

  const LoginScreen({super.key, this.initialRole});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Tab değişimini dinle ve UI'ı güncelle (Buton metni için)
    _tabController.addListener(() {
       // indexIsChanging kontrolü animasyon sırasında değil, geçiş bitince güncellemek için
       // ancak buton metninin anlık değişmesi için direkt setState çağırabiliriz.
       // Genelde user tab'e tıkladığında hemen değişmesi istenir.
       // Basit olması adına her eventte setState çağırıyoruz.
       if (_tabController.indexIsChanging || _tabController.animation != null) {
         setState(() {});
       }
    });
    
    // Animation listener ekleyerek swipe sırasında da smooth geçiş sağlayabiliriz ama 
    // şimdilik basit bir listener yeterli.
    _tabController.animation?.addListener(() {
       // Gerekirse burada da setState çağrılabilir
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    final controller = ref.read(authControllerProvider.notifier);
    
    // Focus'u kapat
    FocusScope.of(context).unfocus();

    if (_tabController.index == 0) {
      // 0. index: Giriş Yap
      final role = widget.initialRole ?? 'tasker';
      await controller.signIn(email: email, password: password, requiredRole: role);
    } else {
      // 1. index: Kayıt Ol
      final role = widget.initialRole ?? 'tasker';
      await controller.signUp(email: email, password: password, role: role);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (!next.isLoading && !next.hasError) {
        // Rotayı '/home' a yönlendir, oradaki logic role göre dağıtacak
        context.go('/home');
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;
    final roleText = widget.initialRole == 'business' ? 'İşveren' : 'Çalışan';
    
    // Tab index'e göre buton metni
    final isLoginTab = _tabController.index == 0;
    final buttonText = isLoginTab ? 'Giriş Yap' : 'Kayıt Ol';

    return Scaffold(
      appBar: AppBar(
        title: Text('$roleText Girişi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Giriş Yap'),
            Tab(text: 'Kayıt Ol'),
          ],
          // Tab tıklandığında da setState tetiklemek için listener zaten var
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Lütfen e-posta girin';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) return 'Şifre en az 6 karakter olmalı';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
