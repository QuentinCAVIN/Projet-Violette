import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/repositories/rest_show_date_repository.dart';
import 'package:violette_front/services/show_date_service.dart';

class _MockShowDateRemoteDataSource extends Mock
    implements ShowDateRemoteDataSource {}

class _MockFirestoreShowDateRepository extends Mock
    implements FirestoreShowDateRepository {}

class _FakeShowDate extends Fake implements ShowDate {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeShowDate());
    registerFallbackValue(DateTime.utc(2000, 1, 1));
  });

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

  group('RestShowDateRepository.updateShowDate', () {
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

    test('met à jour via REST quand uid numérique', () async {
      final showDate = ShowDate(
        uid: '17',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        startMinutes: 20 * 60,
        endMinutes: 22 * 60,
        address: 'Nantes',
        artistsCount: 5,
        fee: 100,
        description: 'Description patch',
        clientContactName: 'Contact',
        clientContactPhone: '0600000000',
      );

      when(
        () => remote.updateShowDate(
          showDateId: any(named: 'showDateId'),
          eventDate: any(named: 'eventDate'),
          meetingTimeMinutes: any(named: 'meetingTimeMinutes'),
          location: any(named: 'location'),
          clientContactName: any(named: 'clientContactName'),
          clientContactPhone: any(named: 'clientContactPhone'),
          showDetails: any(named: 'showDetails'),
        ),
      ).thenAnswer((_) async {});

      await repository.updateShowDate(showDate);

      verify(
        () => remote.updateShowDate(
          showDateId: showDate.uid!,
          eventDate: showDate.date,
          meetingTimeMinutes: showDate.startMinutes,
          location: showDate.address,
          clientContactName: showDate.clientContactName,
          clientContactPhone: showDate.clientContactPhone,
          showDetails: showDate.description,
        ),
      ).called(1);
      verifyNever(() => legacy.updateShowDate(any()));
    });

    test('fallback legacy quand uid non numérique', () async {
      final showDate = ShowDate(
        uid: 'legacy-firestore-id',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        startMinutes: 20 * 60,
        endMinutes: 22 * 60,
        address: 'Nantes',
        artistsCount: 5,
        fee: 100,
      );
      when(() => legacy.updateShowDate(showDate)).thenAnswer((_) async {});

      await repository.updateShowDate(showDate);

      verify(() => legacy.updateShowDate(showDate)).called(1);
      verifyNever(
        () => remote.updateShowDate(
          showDateId: any(named: 'showDateId'),
          eventDate: any(named: 'eventDate'),
          meetingTimeMinutes: any(named: 'meetingTimeMinutes'),
          location: any(named: 'location'),
          clientContactName: any(named: 'clientContactName'),
          clientContactPhone: any(named: 'clientContactPhone'),
          showDetails: any(named: 'showDetails'),
        ),
      );
    });

    test('propage l’erreur REST pour uid numérique', () async {
      final showDate = ShowDate(
        uid: '17',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        startMinutes: 20 * 60,
        endMinutes: 22 * 60,
        address: 'Nantes',
        artistsCount: 5,
        fee: 100,
      );

      when(
        () => remote.updateShowDate(
          showDateId: any(named: 'showDateId'),
          eventDate: any(named: 'eventDate'),
          meetingTimeMinutes: any(named: 'meetingTimeMinutes'),
          location: any(named: 'location'),
          clientContactName: any(named: 'clientContactName'),
          clientContactPhone: any(named: 'clientContactPhone'),
          showDetails: any(named: 'showDetails'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/show-dates/17'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/show-dates/17'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.updateShowDate(showDate),
        throwsA(isA<DioException>()),
      );
      verifyNever(() => legacy.updateShowDate(any()));
    });

    test('lève ArgumentError si uid vide', () async {
      final showDate = ShowDate(
        uid: '   ',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        startMinutes: 20 * 60,
        endMinutes: 22 * 60,
        address: 'Nantes',
        artistsCount: 5,
        fee: 100,
      );

      expect(
        () => repository.updateShowDate(showDate),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => legacy.updateShowDate(any()));
    });
  });
}
