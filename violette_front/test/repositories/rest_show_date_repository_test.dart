import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violette_front/data/remote/show_date_remote_data_source.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/repositories/rest_show_date_repository.dart';

class _MockShowDateRemoteDataSource extends Mock
    implements ShowDateRemoteDataSource {}

class _FakeShowDate extends Fake implements ShowDate {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeShowDate());
    registerFallbackValue(DateTime.utc(2000, 1, 1));
  });

  group('RestShowDateRepository.addShowDate', () {
    late _MockShowDateRemoteDataSource remote;
    late RestShowDateRepository repository;

    setUp(() {
      remote = _MockShowDateRemoteDataSource();
      repository = RestShowDateRepository(remoteDataSource: remote);
    });

    test('lève StateError si aucune compagnie (GET /api/companies/mine vide)', () async {
      when(() => remote.getMyCompanyId()).thenAnswer((_) async => null);

      final showDate = ShowDate(
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        meetingTimeMinutes: 10 * 60,
        address: 'Lieu',
        totalRequiredArtists: 3,
        clientContactName: 'Alice',
        clientContactPhone: '0600000000',
      );

      expect(
        () => repository.addShowDate(showDate),
        throwsA(isA<StateError>()),
      );
      verify(() => remote.getMyCompanyId()).called(1);
      verifyNever(
        () => remote.createShowDate(
          companyId: any(named: 'companyId'),
          eventDate: any(named: 'eventDate'),
          meetingTimeMinutes: any(named: 'meetingTimeMinutes'),
          location: any(named: 'location'),
          clientContactName: any(named: 'clientContactName'),
          clientContactPhone: any(named: 'clientContactPhone'),
          showDetails: any(named: 'showDetails'),
        ),
      );
    });
  });

  group('RestShowDateRepository.deleteShowDate', () {
    late _MockShowDateRemoteDataSource remote;
    late RestShowDateRepository repository;

    setUp(() {
      remote = _MockShowDateRemoteDataSource();
      repository = RestShowDateRepository(
        remoteDataSource: remote,
      );
    });

    test('supprime via REST quand uid numérique', () async {
      when(() => remote.deleteShowDate('15')).thenAnswer((_) async {});

      await repository.deleteShowDate('15');

      verify(() => remote.deleteShowDate('15')).called(1);
    });

    test('propage FormatException quand uid non numérique', () async {
      when(() => remote.deleteShowDate('firestore-doc-id')).thenThrow(
        const FormatException('Identifiant de date invalide pour REST'),
      );

      expect(
        () => repository.deleteShowDate('firestore-doc-id'),
        throwsA(isA<FormatException>()),
      );
    });

    test('ignore DioException 404 (suppression idempotente)', () async {
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

      await repository.deleteShowDate('42');

      verify(() => remote.deleteShowDate('42')).called(1);
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
    });

    test('lève ArgumentError si uid vide', () async {
      expect(
        () => repository.deleteShowDate('   '),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => remote.deleteShowDate(any()));
    });
  });

  group('RestShowDateRepository.updateShowDate', () {
    late _MockShowDateRemoteDataSource remote;
    late RestShowDateRepository repository;

    setUp(() {
      remote = _MockShowDateRemoteDataSource();
      repository = RestShowDateRepository(
        remoteDataSource: remote,
      );
    });

    test('met à jour via REST quand uid numérique', () async {
      final showDate = ShowDate(
        id: '17',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        meetingTimeMinutes: 20 * 60,
        address: 'Nantes',
        totalRequiredArtists: 5,
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
          showDateId: showDate.id,
          eventDate: showDate.date,
          meetingTimeMinutes: showDate.meetingTimeMinutes,
          location: showDate.address,
          clientContactName: showDate.clientContactName,
          clientContactPhone: showDate.clientContactPhone,
          showDetails: showDate.description,
        ),
      ).called(1);
    });

    test('propage FormatException quand uid non numérique', () async {
      final showDate = ShowDate(
        id: 'legacy-firestore-id',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        meetingTimeMinutes: 20 * 60,
        address: 'Nantes',
        totalRequiredArtists: 5,
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
        const FormatException('Identifiant de date invalide pour REST'),
      );

      expect(
        () => repository.updateShowDate(showDate),
        throwsA(isA<FormatException>()),
      );
    });

    test('propage l’erreur REST pour uid numérique', () async {
      final showDate = ShowDate(
        id: '17',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        meetingTimeMinutes: 20 * 60,
        address: 'Nantes',
        totalRequiredArtists: 5,
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
    });

    test('lève ArgumentError si uid vide', () async {
      final showDate = ShowDate(
        id: '   ',
        title: 'Titre',
        date: DateTime.utc(2026, 4, 20),
        meetingTimeMinutes: 20 * 60,
        address: 'Nantes',
        totalRequiredArtists: 5,
      );

      expect(
        () => repository.updateShowDate(showDate),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
