import '../config/constants.dart';

class Roles {
  static bool isAdmin(String? role) {
    return role == AppConstants.roleAdmin;
  }

  static bool isUser(String? role) {
    return role == AppConstants.roleUser;
  }
}
