
import 'package:app/helper/dates_and_times.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Verify Date Copmarisons", () {
      DateTime before = DateTime.now();
      DateTime beforeTwo = DateTime.now();
      DateTime beforeThree = DateTime.now().add(const Duration(seconds: 5));
      DateTime beforeFour = DateTime(2000, 1, 31);
      expect(before.isWithinDateRange(beforeTwo, 'Week'), true);
      expect(before.isWithinDateRange(beforeTwo, 'Month'), true);
      expect(before.isWithinDateRange(beforeTwo, 'Year'), true);
      expect(before.isWithinDateRange(beforeThree, 'Test'), false);
      expect(before.isWithinDateRange(beforeFour, 'Year'), false);
      expect(before.isWithinDateRange(beforeFour, 'Month'), false);
      expect(before.isWithinDateRange(beforeFour, 'Day'), false);
  });

}