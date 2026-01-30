import 'package:flutter_test/flutter_test.dart';
import 'package:violette_front/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ManagerDateDetailViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
