import 'package:violette_front/models/violette_user.dart';

abstract class UserRepository {
  Future<VioletteUser?> getUser(String uid);
  Future<void> addUser(VioletteUser user);
}
