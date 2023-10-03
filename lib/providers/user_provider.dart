import 'package:flutter/widgets.dart';
import 'package:vku_connectx/models/user.dart';
import 'package:vku_connectx/resources/auth_methods.dart';

class UserProvider with ChangeNotifier { // management user in application
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}