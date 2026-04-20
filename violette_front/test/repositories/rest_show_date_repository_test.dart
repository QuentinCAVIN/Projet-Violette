import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';
import 'package:violette_front/repositories/rest_show_date_repository.dart';
import 'package:violette_front/services/show_date_service.dart';

class _MockShowDateRemoteDataSource extends Mock
    implements ShowDateRemoteDataSource {}

class _MockFirestoreShowDateRepository extends Mock
    implements FirestoreShowDateRepository {}

void main() {
  group('RestShowDateRepository.deleteShowDate', () {
    late _MockShowDateRemoteDataSource remote;
    late _MockFirestoreShowDateRepository legacy;
    late RestShowDateRepository repository;

    setUp(() {
      remote = _MockShowDateRemoteDataSource();
      legacy = _MockFirestoreShowDateRepository();
      repository = RestShowDateRepository(
        remoteDataSource: remote,
        legacyRepository: legacy,
      );
    });

    test('supprime via REST quand uid numérique', () async {
      when(() => remote.deleteShowDate('15')).thenAnswer((_) async {});

      await repository.deleteShowDate('15');

      verify(() => remote.deleteShowDate('15')).called(1);
      verifyNever(() => legacy.deleteShowDate(any()));
    });

    test('fallback legacy quand uid non numérique', () async {
      when(() => legacy.deleteShowDate('firestore-doc-id'))
          .thenAnswer((_) async {});

      await repository.deleteShowDate('firestore-doc-id');

      verify(() => legacy.deleteShowDate('firestore-doc-id')).called(1);
      verifyNever(() => remote.deleteShowDate(any()));
    });

    test('fallback legacy quand REST répond 404', () async {
      when(() => remote.deleteShowDate('42')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/show-dates/42'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/show-dates/42'),
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      when(() => legacy.deleteShowDate('42')).thenAnswer((_) async {});

      await repository.deleteShowDate('42');

      verify(() => remote.deleteShowDate('42')).called(1);
      verify(() => legacy.deleteShowDate('42')).called(1);
    });

    test('propage l’erreur REST si statut différent de 404', () async {
      when(() => remote.deleteShowDate('42')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/show-dates/42'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/show-dates/42'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.deleteShowDate('42'),
        throwsA(isA<DioException>()),
      );
      verifyNever(() => legacy.deleteShowDate(any()));
    });

    test('lève ArgumentError si uid vide', () async {
      expect(
        () => repository.deleteShowDate('   '),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => remote.deleteShowDate(any()));
      verifyNever(() => legacy.deleteShowDate(any()));
    });
  });
}
