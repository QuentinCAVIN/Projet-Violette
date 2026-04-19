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

  group('BookingRemoteDataSource.sendConfirmationRequests', () {
    test(
      'appelle POST /show-dates/{id}/send-confirmations sans corps',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        String? postPath;
        Object? postData;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.method == 'POST' &&
                  options.path ==
                      '/api/artist-bookings/show-dates/123/send-confirmations') {
                postPath = options.path;
                postData = options.data;
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <Map<String, dynamic>>[],
                  ),
                );
              }
              fail('Requête inattendue : ${options.method} ${options.path}');
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        await ds.sendConfirmationRequests('123');

        expect(
          postPath,
          '/api/artist-bookings/show-dates/123/send-confirmations',
        );
        expect(postData, isNull);
      },
    );

    test(
      'remonte un message clair si la date est introuvable (404)',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        expect(
          () => ds.sendConfirmationRequests('999'),
          throwsA(
            predicate(
              (Object? e) =>
                  e is Exception &&
                  e.toString().contains('Date de spectacle introuvable'),
            ),
          ),
        );
      },
    );
  });

  group('BookingRemoteDataSource.toggleSelection', () {
    test(
      'sélection : POST /api/artist-bookings avec showDateId et artistId',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        Object? posted;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.method == 'POST' &&
                  options.path == '/api/artist-bookings') {
                posted = options.data;
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 201,
                    data: <String, dynamic>{'id': 1},
                  ),
                );
              }
              fail('Requête inattendue : ${options.method} ${options.path}');
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        await ds.toggleSelection('10', '2', true);

        expect(posted, <String, dynamic>{'showDateId': 10, 'artistId': 2});
      },
    );

    test(
      'désélection : GET show-dates puis DELETE le booking SELECTED',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        String? deletedPath;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.method == 'GET' &&
                  options.path == '/api/artist-bookings/show-dates/10') {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <Map<String, dynamic>>[
                      {
                        'id': 77,
                        'artistId': 2,
                        'status': 'SELECTED',
                      },
                    ],
                  ),
                );
              }
              if (options.method == 'DELETE' &&
                  options.path == '/api/artist-bookings/77') {
                deletedPath = options.path;
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 204,
                  ),
                );
              }
              fail('Requête inattendue : ${options.method} ${options.path}');
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        await ds.toggleSelection('10', '2', false);

        expect(deletedPath, '/api/artist-bookings/77');
      },
    );

    test(
      'lève une exception si aucun booking serveur pour la désélection',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: <Map<String, dynamic>>[],
                ),
              );
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        expect(
          () => ds.toggleSelection('10', '2', false),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
