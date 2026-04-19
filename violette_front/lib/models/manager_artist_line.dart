import 'package:violette_front/models/violette_user.dart';

/// Une ligne de la liste « artistes » sur l’écran détail date gérant.
///
/// [apiArtistId] est l’identifiant backend (SQL) aligné sur les disponibilités
/// et les appels REST `ArtistBooking` ; [user] sert à l’affichage (nom, email).
class ManagerArtistLine {
  const ManagerArtistLine({
    required this.user,
    required this.apiArtistId,
  });

  final VioletteUser user;
  final String apiArtistId;
}
