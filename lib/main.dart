import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/account/account_page.dart';
import 'package:tennis_app_front/pages/home/home_page.dart';
import 'package:tennis_app_front/pages/login_page.dart';
import 'package:tennis_app_front/pages/places/places_page.dart';
import 'package:tennis_app_front/pages/search_match/search_match_page.dart';
import 'package:tennis_app_front/pages/wrapper.dart';
import 'package:tennis_app_front/services/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // void _getUserPosition() async {
  //   final Position position = await Geolocator()
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  // }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'TennisApp',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: Wrapper(),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) => new LoginPage(),
          '/home': (BuildContext context) => new HomePage(),
          '/search_match': (BuildContext context) => new SearchMatchPage(),
          '/places': (BuildContext context) => new PlacesPage(),
          '/account': (BuildContext context) => new AccountPage(),
        },
      ),
    );
  }
}

// Future<bool> isUserLoggedIn() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   final String authorization = prefs.getString('Authorization');

//   return authorization != null;
// }
