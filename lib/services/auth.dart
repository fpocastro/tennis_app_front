import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class AuthService {
  final String loginUrl = globals.apiMainUrl + '/api/auth/login';
  final String registerUrl = globals.apiMainUrl + '/api/auth/register';

  Future<User> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userInfoStr = prefs.getString('UserInfo');
    if (userInfoStr != null) {
      final userInfo = json.decode(userInfoStr);
      User user = new User.fromJson(userInfo);
      return user;
    } else {
      return null;
    }
  }

  Future<String> getAuthorizationToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('Authorization');
    return token;
  }

  Future<bool> setCurrentUser(user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userObj = json.decode(user);
      prefs.setString('UserInfo', json.encode(userObj));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> setAuthorizationToken(token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('Authorization', token);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<int> signInWithEmailAndPassword(String email, String password) async {
    try {
      final body = new Map<String, dynamic>();
      body['email'] = email;
      body['password'] = password;

      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=utf-8'
      };

      http.Response response = await http.post(
        loginUrl,
        body: json.encode(body),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await setCurrentUser(response.body);
        await setAuthorizationToken(response.headers['authorization']);
      }

      return response.statusCode;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<int> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final body = new Map<String, dynamic>();
      body['email'] = email;
      body['password'] = password;
      body['name'] = name;

      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=utf-8'
      };

      http.Response response = await http.post(
        registerUrl,
        body: json.encode(body),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await setCurrentUser(response.body);
        await setAuthorizationToken(response.headers['authorization']);
      }

      return response.statusCode;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('UserInfo', null);
    return null;
  }
}
