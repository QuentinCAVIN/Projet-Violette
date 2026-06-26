import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:violette_front/ui/widgets/common/calendar/calendar_day_cell.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  group('CalendarDayCell Tests -', () {
    testWidgets(
        'When color is null and not selected/today, should render simple text without colored decoration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              day: DateTime(2025, 1, 1),
              color: null,
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsNothing,
          reason:
              "Ne doit pas y avoir de Container (donc pas de décoration/couleur) si color est null");

      final textFinder = find.text('${DateTime(2025, 1, 1).day}');
      expect(textFinder, findsOneWidget);
    });

    testWidgets('When color is provided, should render colored circle',
        (WidgetTester tester) async {
      const testColor = Colors.red;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              day: DateTime(2025, 1, 1),
              color: testColor,
            ),
          ),
        ),
      );

      final Container container = tester.widget(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      expect(decoration.color, testColor);
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets(
        'whenStatusLabelIsProvided_shouldExposeSemanticsLabelWithDateAndStatus',
        (WidgetTester tester) async {
      final testDay = DateTime(2026, 3, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              day: testDay,
              color: Colors.green,
              statusLabel: 'Disponible',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CalendarDayCell));
      expect(semantics.label, '15 mars 2026, Disponible');
    });

    testWidgets(
        'whenStatusLabelIsNull_shouldExposeSemanticsLabelWithDateOnly',
        (WidgetTester tester) async {
      final testDay = DateTime(2026, 3, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              day: testDay,
              color: null,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CalendarDayCell));
      expect(semantics.label, '15 mars 2026');
    });
  });
}
