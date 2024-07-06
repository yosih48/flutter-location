import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/user.dart';
import '../resources/auth.dart';


class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

 User? get getUser => _user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}