import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyer/features/auth/presentation/providers/auth_state_provider.dart';

/// A [Listenable] that notifies when the auth state changes.
/// This is used for [GoRouter.refreshListenable].
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AsyncValue<AuthState>> _subscription;

  GoRouterRefreshStream(Stream<AsyncValue<AuthState>> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Yeni bir Provider: Stream'i GoRouter için Listenable'a çevirir
final goRouterRefreshStreamProvider = Provider<ChangeNotifier>((ref) {
  // authStateProvider.stream, bize AsyncValue<AuthState> stream'i vermez.
  // StreamProvider'dan stream almak için .stream modifier kullanılır ama o ham veriyi verir.
  // Burada ref.listen kullanarak manuel bir stream oluşturmak yerine
  // StreamProvider'ın kendisini dinleyip notify etmek daha reaktif olabilir.
  // Ancak GoRouterRefreshStream pattern'i genelde Stream<T> alır.
  
  // Basitlik adina: authRepository'den gelen ham stream'i kullanalım.
  // Fakat riverpod 'provider' mantığında kalmak için:
  // StreamProvider'ın stream özelliğini kullanabiliriz.
  
  // Düzeltme: StreamProvider.stream bize Stream<AuthState> döner.
  // AsyncValue sarmalayıcısı olmadan ham stream.
  
  // ref.read(authStateProvider.stream) => Stream<AuthState>
  // Ancak bu future/stream providerlar autoDispose olabilir, dikkat etmek gerek.
  // Şimdilik authStateProvider autoDispose değil (default).
  
  // Daha basit bir yol: GoRouterRefreshStream'e direkt ref.watch(authStateProvider.stream) verelim.
  // Fakat authStateProvider StreamProvider olduğu için .stream propertysi yok, .future var veya kendisi var.
  // StreamProvider'ı dinlemek için ref.listenManual daha mantıklı ama object döndürmemiz lazım.

  // Geri adım: En temiz yöntem AuthState değişimini dinleyen basit bir ValueNotifier döndürmek.
  
  final notifier = _GoRouterRefreshNotifier();
  
  // AuthState değişimini dinle ve notifier'ı tetikle
  final sub = ref.listen(authStateProvider, (prev, next) {
      notifier.notify();
  });
  
  ref.onDispose(() => sub.close());

  return notifier;
});

class _GoRouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
