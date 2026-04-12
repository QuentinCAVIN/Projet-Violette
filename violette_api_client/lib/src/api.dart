//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:violette_api_client/src/serializers.dart';
import 'package:violette_api_client/src/auth/api_key_auth.dart';
import 'package:violette_api_client/src/auth/basic_auth.dart';
import 'package:violette_api_client/src/auth/bearer_auth.dart';
import 'package:violette_api_client/src/auth/oauth.dart';
import 'package:violette_api_client/src/api/compagnies_api.dart';
import 'package:violette_api_client/src/api/dates_de_spectacle_api.dart';
import 'package:violette_api_client/src/api/rservations_artistes_api.dart';
import 'package:violette_api_client/src/api/sant_api.dart';
import 'package:violette_api_client/src/api/utilisateurs_api.dart';

class VioletteApiClient {
  static const String basePath = r'http://localhost:8080';

  final Dio dio;
  final Serializers serializers;

  VioletteApiClient({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get CompagniesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CompagniesApi getCompagniesApi() {
    return CompagniesApi(dio, serializers);
  }

  /// Get DatesDeSpectacleApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DatesDeSpectacleApi getDatesDeSpectacleApi() {
    return DatesDeSpectacleApi(dio, serializers);
  }

  /// Get RservationsArtistesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RservationsArtistesApi getRservationsArtistesApi() {
    return RservationsArtistesApi(dio, serializers);
  }

  /// Get SantApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SantApi getSantApi() {
    return SantApi(dio, serializers);
  }

  /// Get UtilisateursApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UtilisateursApi getUtilisateursApi() {
    return UtilisateursApi(dio, serializers);
  }
}
