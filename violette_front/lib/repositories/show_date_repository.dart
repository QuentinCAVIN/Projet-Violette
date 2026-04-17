import 'package:violette_front/models/show_date.dart';

abstract class ShowDateRepository {
  /// Écoute en temps réel une date de spectacle via Firestore.
  ///
  /// @deprecated : cette méthode délègue encore au legacy Firestore.
  /// Ne pas utiliser dans de nouveaux développements — préférer [getShowDateById].
  /// Sera supprimée après la migration complète du domaine booking.
  @Deprecated(
    'Délègue à Firestore. Utiliser getShowDateById à la place. '
    'À supprimer après migration complète du domaine booking.',
  )
  Stream<ShowDate> watchShowDate(String dateId);
  Future<List<ShowDate>> getAllShowDates();
  Future<ShowDate?> getShowDateById(String dateId);
  Future<void> addShowDate(ShowDate showDate);
  Future<void> updateShowDate(ShowDate updated);
  Future<void> deleteShowDate(String uid);
  Future<void> updateAllShowDates(List<ShowDate> updatedList);
}
