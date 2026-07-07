import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/data/remote/booking_remote_data_source.dart';
import 'package:violette_front/models/enums/booking_status.dart';

void main() {
  group('BookingRemoteDataSource - Réponse à une demande de confirmation', () {
    test(
      'respondToRequest_whenAccepting_fetchesPendingThenPatchesRespondWithAcceptTrue',
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
      'respondToRequest_whenDeclining_fetchesPendingThenPatchesRespondWithAcceptFalse',
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

    test('respondToRequest_whenNoBookingMatches_throwsExplicitException', () async {
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
      'respondToRequest_whenNoPendingBookingMatchesDate_neverSendsPatch',
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

    test('respondToRequest_whenBackendReturns409_surfacesResponseBodyText', () async {
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

  group('BookingRemoteDataSource - Annulation d\'une réservation', () {
    test(
      'cancelBooking_whenBookingExists_fetchesShowDateBookingsThenPatchesCancelWithoutBody',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        String? patchedPath;
        Object? patchedData;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.method == 'GET' &&
                  options.path == '/api/artist-bookings/show-dates/7') {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <Map<String, dynamic>>[
                      {
                        'id': 42,
                        'artistId': 5,
                        'showDateId': 7,
                        'status': 'CONFIRMED',
                      },
                    ],
                  ),
                );
              }
              if (options.method == 'PATCH' &&
                  options.path == '/api/artist-bookings/42/cancel') {
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
        await ds.cancelBooking('7', '5');

        expect(patchedPath, '/api/artist-bookings/42/cancel');
        expect(patchedData, isNull);
      },
    );

    test('cancelBooking_whenNoBookingMatches_throwsExplicitException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: <Map<String, dynamic>>[
                  {
                    'id': 1,
                    'artistId': 99,
                    'showDateId': 7,
                    'status': 'CONFIRMED',
                  },
                ],
              ),
            );
          },
        ),
      );

      final ds = BookingRemoteDataSource(dio: dio);
      expect(
        () => ds.cancelBooking('7', '5'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('BookingRemoteDataSource - Envoi des demandes de confirmation', () {
    test(
      'sendConfirmationRequests_whenCalled_postsSendConfirmationsWithoutBody',
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
      'sendConfirmationRequests_whenShowDateIsNotFound_throwsExplicitMessage',
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

  group('BookingRemoteDataSource - Bascule de sélection', () {
    test(
      'toggleSelection_whenSelecting_postsBookingWithShowDateIdAndArtistId',
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
      'toggleSelection_whenDeselecting_fetchesBookingsThenDeletesSelectedBooking',
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
      'toggleSelection_whenDeselectingWithoutServerBooking_throwsException',
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

  group('BookingRemoteDataSource - Récupération des réservations d\'une date', () {
    test(
      'getBookingsForDate_whenBackendReturnsBookings_returnsArtistBookingList',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(
                options.path,
                '/api/artist-bookings/show-dates/7',
              );
              expect(options.method, 'GET');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: <Map<String, dynamic>>[
                    {
                      'id': 1,
                      'artistId': 5,
                      'showDateId': 7,
                      'status': 'SELECTED',
                    },
                    {
                      'id': 2,
                      'artistId': 8,
                      'showDateId': 7,
                      'status': 'PENDING_CONFIRMATION',
                    },
                  ],
                ),
              );
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        final bookings = await ds.getBookingsForDate('7');

        expect(bookings.length, 2);
        expect(bookings[0].artistId, '5');
        expect(bookings[1].artistId, '8');
      },
    );

    test(
      'getBookingsForDate_whenBackendReturns404_returnsEmptyList',
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
        final bookings = await ds.getBookingsForDate('999');

        expect(bookings, isEmpty);
      },
    );

    test(
      'getBookingsForDate_whenHttpErrorIsNot404_throwsException',
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
                    statusCode: 500,
                    data: 'Internal Server Error',
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        expect(
          () => ds.getBookingsForDate('7'),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('BookingRemoteDataSource - Demandes en attente pour un artiste', () {
    test(
      'getPendingRequestsForArtist_whenCalled_fetchesPendingAndReturnsArtistBookings',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/api/artist-bookings/me/pending');
              expect(options.method, 'GET');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: <Map<String, dynamic>>[
                    {
                      'id': 42,
                      'artistId': 5,
                      'showDateId': 7,
                      'status': 'PENDING_CONFIRMATION',
                    },
                  ],
                ),
              );
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        final list = await ds.getPendingRequestsForArtist();

        expect(list.length, 1);
        expect(list.first.artistId, '5');
        expect(list.first.dateId, '7');
        expect(list.first.status, BookingStatus.pendingConfirmation);
      },
    );

    test(
      'getPendingRequestsForArtist_whenBackendReturnsHttpError_throwsException',
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
                    statusCode: 503,
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );

        final ds = BookingRemoteDataSource(dio: dio);
        expect(
          () => ds.getPendingRequestsForArtist(),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
