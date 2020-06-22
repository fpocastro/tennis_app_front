import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tennis_app_front/pages/account/account_page.dart';
import 'package:tennis_app_front/pages/chat/messages_page.dart';
import 'package:tennis_app_front/pages/home/home_page.dart';
import 'package:tennis_app_front/pages/login_page.dart';
import 'package:tennis_app_front/pages/places/places_page.dart';
import 'package:tennis_app_front/pages/players/players_page.dart';
import 'package:tennis_app_front/pages/search_match/matches_page.dart';
import 'package:tennis_app_front/pages/search_match/search_match_page.dart';
import 'package:tennis_app_front/pages/wrapper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
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
        '/messages': (BuildContext context) => new MessagesPage(),
        '/players': (BuildContext context) => new PlayersPage(),
        '/matches': (BuildContext context) => new MatchesPage(),
      },
    );
  }
}
