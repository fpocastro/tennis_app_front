import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/home/home_page.dart';
import 'package:tennis_app_front/pages/login_page.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);
    if (user == null) {
      return LoginPage();
    } else {
      return HomePage();
    }
  }
}