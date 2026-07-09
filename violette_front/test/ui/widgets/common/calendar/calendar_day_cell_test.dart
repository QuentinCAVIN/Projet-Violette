import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/widgets/common/calendar/calendar_day_cell.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  double contrastRatio(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final lighter = foregroundLuminance > backgroundLuminance
        ? foregroundLuminance
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance
        ? backgroundLuminance
        : foregroundLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  group('contrastTextForStatusPill', () {
    test('whenBackgroundIsDark_returnsWhite', () {
      expect(
        contrastTextForStatusPill(const Color(0xFF2E7D32)),
        Colors.white,
      );
    });

    test('whenBackgroundIsBright_returnsDarkText', () {
      expect(
        contrastTextForStatusPill(const Color(0xFFFFAB00)),
        VioletteTheme.backgroundGradientTop,
      );
    });

    test('meetsWcagAaOnAllAvailabilityStatusColors', () {
      for (final status in AvailabilityStatus.values) {
        final textColor = contrastTextForStatusPill(status.color);
        expect(
          contrastRatio(textColor, status.color),
          greaterThanOrEqualTo(4.5),
          reason: status.name,
        );
      }
    });

    test('meetsWcagAaOnAllShowDateStatusColors', () {
      for (final status in ShowDateStatus.values) {
        final textColor = contrastTextForStatusPill(status.color);
        expect(
          contrastRatio(textColor, status.color),
          greaterThanOrEqualTo(4.5),
          reason: status.name,
        );
      }
    });
  });

  group('CalendarDayCell - Cellule de jour du calendrier', () {
    testWidgets(
        'whenColorIsNullAndDayIsNotSelectedOrToday_rendersPlainTextWithoutDecoration',
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

    testWidgets('whenColorIsProvided_rendersColoredCircle',
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

      final Text dayText = tester.widget(find.text('1'));
      expect(dayText.style?.color, contrastTextForStatusPill(testColor));
    });

    testWidgets(
        'whenStatusLabelIsProvided_exposesSemanticsLabelWithDateAndStatus',
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
        'whenStatusLabelIsNull_exposesSemanticsLabelWithDateOnly',
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
