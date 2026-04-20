import 'package:violette_front/models/show_date.dart';

abstract class ShowDateRepository {
  Future<List<ShowDate>> getAllShowDates();
  Future<ShowDate?> getShowDateById(String dateId);
  Future<void> addShowDate(ShowDate showDate);
  Future<void> updateShowDate(ShowDate updated);
  Future<void> deleteShowDate(String uid);
}
