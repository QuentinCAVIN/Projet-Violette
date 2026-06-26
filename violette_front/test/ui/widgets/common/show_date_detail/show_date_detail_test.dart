import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/widgets/common/show_date_detail/show_date_detail.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  group('ShowDateDetail Tests -', () {
    testWidgets(
        'whenStatusIsProvided_exposesLiveRegionWithDateAndStatusLabel',
        (WidgetTester tester) async {
      final showDate = ShowDate(
        id: 'show-date-1',
        title: 'Gala Violette',
        date: DateTime(2026, 11, 8),
        meetingTimeMinutes: 18 * 60,
        address: 'Paris',
        totalRequiredArtists: 4,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowDateDetail(
              showDate: showDate,
              status: AvailabilityStatus.available,
            ),
          ),
        ),
      );

      final liveRegionFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.liveRegion == true,
      );
      expect(liveRegionFinder, findsOneWidget);

      final semantics = tester.getSemantics(liveRegionFinder);
      expect(semantics.label, '8 novembre 2026, Disponible');
    });
  });
}
