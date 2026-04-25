import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Client HTTP Dio configuré pour le backend Violette.
///
/// Responsabilités :
/// - Définir la base URL du backend
/// - Injecter le token Firebase JWT dans chaque requête via un intercepteur
class DioClient {
  /// URL de base du backend Violette (port Quarkus par défaut : 8080).
  ///
  /// **Téléphone physique branché en USB (ton cas)** : `127.0.0.1` fonctionne
  /// si tu rediriges le port depuis le PC vers l’appareil :
  /// `adb reverse tcp:8080 tcp:8080`
  /// (à refaire après reconnexion USB si besoin).
  ///
  /// **Émulateur Android** : utiliser `http://10.0.2.2:8080` (alias « localhost du PC »).
  /// `10.0.2.2` ne marche **pas** sur un vrai téléphone.
  ///
  /// **Téléphone sur le même Wi‑Fi que le PC** (sans adb reverse) : mettre l’IP
  /// locale du PC, ex. `http://192.168.1.42:8080` (cmd Windows : `ipconfig`).
  ///
  /// **Production** : passer l'URL Fly.io au build :
  /// `--dart-define=API_BASE_URL=https://violette-back.fly.dev`
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_FirebaseJwtInterceptor());

    return dio;
  }
}

/// Intercepteur Dio : récupère le token Firebase de l'utilisateur courant
/// et l'ajoute en header Authorization avant chaque requête.
class _FirebaseJwtInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // forceRefresh: false → utilise le token en cache si encore valide
      final token = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
