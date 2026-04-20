import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';

void main() {
  group('ShowDateRemoteDataSource.getMyCompanyId', () {
    test('retourne l\'id de compagnie depuis GET /api/companies/mine', () async {
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

    test('retourne null si le backend répond 404', () async {
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

    test('propage une erreur HTTP autre que 404', () async {
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
}
