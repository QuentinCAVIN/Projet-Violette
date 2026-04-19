import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/data/remote/booking_remote_data_source.dart';

void main() {
  group('BookingRemoteDataSource.respondToRequest', () {
    test(
      'enchaîne GET /me/pending puis PATCH /{id}/respond avec accept',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        String? patchedPath;
        Object? patchedData;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path == '/api/artist-bookings/me/pending' &&
                  options.method == 'GET') {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <Map<String, dynamic>>[
                      {
                        'id': 42,
                        'showDateId': 7,
                        'status': 'PENDING_CONFIRMATION',
                      },
                    ],
                  ),
                );
              }
              if (options.method == 'PATCH' &&
                  options.path == '/api/artist-bookings/42/respond') {
                patchedPath = options.path;
                patchedData = options.data;
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{'id': 42},
                  ),
                );
              }
              fail('Requête inattendue : ${options.method} ${options.path}');
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        await ds.respondToRequest('7', 'artist-x', true);

        expect(patchedPath, '/api/artist-bookings/42/respond');
        expect(patchedData, <String, dynamic>{'accept': true});
      },
    );

    test(
      'enchaîne GET /me/pending puis PATCH avec accept: false pour un refus',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        String? patchedPath;
        Object? patchedData;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path == '/api/artist-bookings/me/pending' &&
                  options.method == 'GET') {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <Map<String, dynamic>>[
                      {
                        'id': 99,
                        'showDateId': 3,
                        'status': 'PENDING_CONFIRMATION',
                      },
                    ],
                  ),
                );
              }
              if (options.method == 'PATCH' &&
                  options.path == '/api/artist-bookings/99/respond') {
                patchedPath = options.path;
                patchedData = options.data;
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{'id': 99},
                  ),
                );
              }
              fail('Requête inattendue : ${options.method} ${options.path}');
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        await ds.respondToRequest('3', 'artist-x', false);

        expect(patchedPath, '/api/artist-bookings/99/respond');
        expect(patchedData, <String, dynamic>{'accept': false});
      },
    );

    test('lève une exception explicite si aucun booking ne correspond', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: <Map<String, dynamic>>[
                  {'id': 1, 'showDateId': 99, 'status': 'PENDING_CONFIRMATION'},
                ],
              ),
            );
          },
        ),
      );

      final ds = BookingRemoteDataSource(dio: dio);
      expect(
        () => ds.respondToRequest('7', 'a', true),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'ne déclenche aucun PATCH si aucun booking PENDING_CONFIRMATION ne '
      'correspond à la date',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        var patchCount = 0;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path == '/api/artist-bookings/me/pending' &&
                  options.method == 'GET') {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <Map<String, dynamic>>[
                      {
                        'id': 1,
                        'showDateId': 7,
                        'status': 'CONFIRMED',
                      },
                    ],
                  ),
                );
              }
              if (options.method == 'PATCH') {
                patchCount++;
              }
              fail('PATCH inattendu : ${options.path}');
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        await expectLater(
          () => ds.respondToRequest('7', 'a', true),
          throwsA(isA<Exception>()),
        );
        expect(patchCount, 0);
      },
    );

    test('remonte le corps texte du backend en 409', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/api/artist-bookings/me/pending') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: <Map<String, dynamic>>[
                    {
                      'id': 42,
                      'showDateId': 7,
                      'status': 'PENDING_CONFIRMATION',
                    },
                  ],
                ),
              );
            }
            if (options.path == '/api/artist-bookings/42/respond') {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 409,
                    data: 'Transition interdite',
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            }
            fail('unexpected');
          },
        ),
      );

      final ds = BookingRemoteDataSource(dio: dio);
      try {
        await ds.respondToRequest('7', 'a', false);
        fail('devrait lever');
      } on Exception catch (e) {
        expect(e.toString(), contains('Transition interdite'));
      }
    });
  });
}
