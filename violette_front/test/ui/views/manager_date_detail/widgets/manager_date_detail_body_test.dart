import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/manager_date_detail_body.dart';

import '../../../../helpers/test_helpers.dart';

const _openFullDetailLabel = 'Détail, ouvrir la fiche complète de la date';

void main() {
  group('ManagerDateDetailBody - Corps du détail de date gérant', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    final showDate = ShowDate(
      id: '',
      title: 'Gala Violette',
      date: DateTime(2026, 3, 15),
      meetingTimeMinutes: 510,
      address: 'Paris',
      totalRequiredArtists: 2,
    );

    group('Accessibilité', () {
      testWidgets(
        'openFullDetailButton_whenInlineDetailRendered_exposesDistinctFocusableButtonNode',
        (tester) async {
          final handle = tester.ensureSemantics();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Card(
                  child:
                      ViewModelBuilder<ManagerDateDetailViewModel>.nonReactive(
                    viewModelBuilder: () =>
                        ManagerDateDetailViewModel(showDate: showDate),
                    builder: (context, viewModel, child) =>
                        ManagerDateDetailBody(
                      isInline: true,
                      onOpenFullDetail: () {},
                    ),
                  ),
                ),
              ),
            ),
          );

          final detailNodeFinder = find.semantics.byLabel(_openFullDetailLabel);
          expect(detailNodeFinder, findsOneWidget);

          final detailNode = detailNodeFinder.evaluate().single;
          expect(
            detailNode.isMergedIntoParent,
            isFalse,
            reason: 'Le bouton ne doit pas être fusionné dans un nœud parent',
          );
          expect(detailNode.flagsCollection.isButton, isTrue);
          expect(
            detailNode.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );

          expect(
            tester.semantics.simulatedAccessibilityTraversal(),
            contains(
              isSemantics(
                label: _openFullDetailLabel,
                isButton: true,
                hasTapAction: true,
              ),
            ),
          );

          handle.dispose();
        },
      );
    });
  });
}
