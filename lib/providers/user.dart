import 'dart:convert';

import 'package:app/models/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _token;

  bool get isLogged {
    return token != null;
  }

  String get token {
    return _token;
  }

  Future<void> _login(String newToken) async {
    _token = newToken;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'userData',
        json.encode({
          'token': _token,
        }));

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    var response = await Api.post(
      endpoint: '/v1/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    await _login(response['token']);
  }

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');

    _token = null;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    final response = await Api.post(
      endpoint: '/v1/register',
      body: {
        'email': email,
        'password': password,
      },
    );

    await _login(response['token']);
  }

  Future<bool> tryAutoLogin() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }

    var userData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    if (userData['token'] == null) {
      return false;
    }

    _token = userData['token'];
    notifyListeners();

    return true;
  }
}
