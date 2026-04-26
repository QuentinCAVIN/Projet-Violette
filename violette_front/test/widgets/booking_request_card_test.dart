import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/widgets/booking_request_card.dart';

void main() {
  group('BookingRequestCard -', () {
    final showDate = ShowDate(
      id: 'sd-1',
      title: 'Cabaret',
      date: DateTime(2026, 3, 15),
      meetingTimeMinutes: 510,
      address: 'Paris',
      totalRequiredArtists: 2,
    );

    testWidgets(
      'whenStatusIsPendingConfirmation_showsConfirmerAndRefuser',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingRequestCard(
                booking: ArtistBooking(
                  artistId: 'art-1',
                  dateId: 'sd-1',
                  status: BookingStatus.pendingConfirmation,
                ),
                showDate: showDate,
                onAccept: () {},
                onRefuse: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirmer'), findsOneWidget);
        expect(find.text('Refuser'), findsOneWidget);
      },
    );

    testWidgets(
      'whenStatusIsConfirmed_doesNotShowActionButtons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingRequestCard(
                booking: ArtistBooking(
                  artistId: 'art-1',
                  dateId: 'sd-1',
                  status: BookingStatus.confirmed,
                ),
                showDate: showDate,
                onAccept: () {},
                onRefuse: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirmer'), findsNothing);
        expect(find.text('Refuser'), findsNothing);
        expect(find.text('Confirmé'), findsOneWidget);
      },
    );

    testWidgets(
      'whenConfirmerIsTapped_invokesOnAccept',
      (tester) async {
        var acceptCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingRequestCard(
                booking: ArtistBooking(
                  artistId: 'art-1',
                  dateId: 'sd-1',
                  status: BookingStatus.pendingConfirmation,
                ),
                showDate: showDate,
                onAccept: () => acceptCalls++,
                onRefuse: () {},
              ),
            ),
          ),
        );

        await tester.tap(find.text('Confirmer'));
        expect(acceptCalls, 1);
      },
    );

    testWidgets(
      'whenRefuserIsTapped_invokesOnRefuse',
      (tester) async {
        var refuseCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingRequestCard(
                booking: ArtistBooking(
                  artistId: 'art-1',
                  dateId: 'sd-1',
                  status: BookingStatus.pendingConfirmation,
                ),
                showDate: showDate,
                onAccept: () {},
                onRefuse: () => refuseCalls++,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Refuser'));
        expect(refuseCalls, 1);
      },
    );

    testWidgets(
      'whenPendingConfirmationAndShowDateNull_showsFallbackMessageAndButtonsWithoutFakeDate',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingRequestCard(
                booking: ArtistBooking(
                  artistId: 'art-1',
                  dateId: 'unknown-id',
                  status: BookingStatus.pendingConfirmation,
                ),
                showDate: null,
                onAccept: () {},
                onRefuse: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirmer'), findsOneWidget);
        expect(find.text('Refuser'), findsOneWidget);
        expect(
          find.text('Détails de la date indisponibles pour le moment'),
          findsOneWidget,
        );
        expect(find.text('Demande de confirmation'), findsOneWidget);
        expect(find.text('1/1/2000'), findsNothing);
      },
    );
  });
}
