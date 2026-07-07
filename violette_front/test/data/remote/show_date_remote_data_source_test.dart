import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';

void main() {
  group('ShowDateRemoteDataSource - Récupération de l\'identifiant compagnie', () {
    test('getMyCompanyId_whenBackendReturnsCompany_returnsCompanyId', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'GET');
            expect(options.path, '/api/companies/mine');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'id': 42, 'name': 'Compagnie Alpha'},
              ),
            );
          },
        ),
      );

      final ds = ShowDateRemoteDataSource(dio: dio);
      final companyId = await ds.getMyCompanyId();

      expect(companyId, '42');
    });

    test('getMyCompanyId_whenBackendReturns404_returnsNull', () async {
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

      final ds = ShowDateRemoteDataSource(dio: dio);
      final companyId = await ds.getMyCompanyId();

      expect(companyId, isNull);
    });

    test('getMyCompanyId_whenHttpErrorIsNot404_rethrowsError', () async {
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
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final ds = ShowDateRemoteDataSource(dio: dio);
      expect(() => ds.getMyCompanyId(), throwsA(isA<DioException>()));
    });
  });

  group('ShowDateRemoteDataSource - Suppression d\'une date', () {
    test('deleteShowDate_whenIdIsNumeric_callsDeleteEndpoint', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      String? deletedPath;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'DELETE') {
              deletedPath = options.path;
              return handler.resolve(
                Response(requestOptions: options, statusCode: 204),
              );
            }
            fail('Requête inattendue : ${options.method} ${options.path}');
          },
        ),
      );

      final ds = ShowDateRemoteDataSource(dio: dio);
      await ds.deleteShowDate('12');

      expect(deletedPath, '/api/show-dates/12');
    });

    test('deleteShowDate_whenIdIsBlank_throwsArgumentError', () async {
      final ds = ShowDateRemoteDataSource(dio: Dio());
      expect(
        () => ds.deleteShowDate('   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deleteShowDate_whenIdIsNotNumeric_throwsFormatException', () async {
      final ds = ShowDateRemoteDataSource(dio: Dio());
      expect(
        () => ds.deleteShowDate('abc'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ShowDateRemoteDataSource - Mise à jour d\'une date', () {
    test('updateShowDate_whenIdIsNumeric_callsPatchEndpointWithFormattedPayload', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      String? patchPath;
      Map<String, dynamic>? patchPayload;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'PATCH') {
              patchPath = options.path;
              patchPayload = Map<String, dynamic>.from(
                options.data as Map<dynamic, dynamic>,
              );
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: <String, dynamic>{'id': 12},
                ),
              );
            }
            fail('Requête inattendue : ${options.method} ${options.path}');
          },
        ),
      );

      final ds = ShowDateRemoteDataSource(dio: dio);
      await ds.updateShowDate(
        showDateId: '12',
        eventDate: DateTime.utc(2026, 4, 20),
        meetingTimeMinutes: 19 * 60 + 30,
        location: 'Paris 11e',
        clientContactName: 'Alice Martin',
        clientContactPhone: '0601020304',
        showDetails: 'Version patch',
      );

      expect(patchPath, '/api/show-dates/12');
      expect(
        patchPayload,
        <String, dynamic>{
          'eventDate': '2026-04-20',
          'meetingTime': '19:30:00',
          'location': 'Paris 11e',
          'clientContactName': 'Alice Martin',
          'clientContactPhone': '0601020304',
          'showDetails': 'Version patch',
        },
      );
    });

    test('updateShowDate_whenIdIsBlank_throwsArgumentError', () async {
      final ds = ShowDateRemoteDataSource(dio: Dio());
      expect(
        () => ds.updateShowDate(showDateId: '  '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateShowDate_whenIdIsNotNumeric_throwsFormatException', () async {
      final ds = ShowDateRemoteDataSource(dio: Dio());
      expect(
        () => ds.updateShowDate(showDateId: 'abc'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
