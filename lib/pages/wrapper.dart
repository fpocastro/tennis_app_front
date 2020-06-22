import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/home/home_page.dart';
import 'package:tennis_app_front/pages/introduction/intro_first_page.dart';
import 'package:tennis_app_front/pages/login_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/loading.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else if (snapshot.connectionState == ConnectionState.done){
          if (snapshot.data == null) {
            return LoginPage();
          } else {
            return snapshot.data.introduction ? HomePage() : IntroFirstPage();
          }
        } else {
          return LoginPage();
        }
      },
    );
  }
}
