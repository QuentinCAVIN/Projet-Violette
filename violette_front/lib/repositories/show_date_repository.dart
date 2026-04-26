import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/show_date_status.dart';

abstract class ShowDateRepository {
  Future<List<ShowDate>> getAllShowDates();
  Future<List<ShowDate>> getMyAvailableShowDates();
  Future<ShowDate?> getShowDateById(String dateId);
  Future<void> addShowDate(ShowDate showDate);
  Future<void> updateShowDate(ShowDate updated);
  Future<void> updateShowDateStatus(String showDateId, ShowDateStatus status);
  Future<void> deleteShowDate(String uid);
}
