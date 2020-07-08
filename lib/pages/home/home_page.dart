import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/models/match.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:tennis_app_front/shared/loading.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  final AuthService _auth = AuthService();
  User _user;
  List<Match> _pendingMatches = [];
  List<Match> _closedMatches = [];
  Map<String, dynamic> _performance = {};

  void loadHome() async {
    setState(() {
      _loading = true;
    });
    // Position position = await Geolocator()
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    _pendingMatches = await _loadMatches('pending');
    _closedMatches = await _loadMatches('closed');
    _performance = await _loadPlayerPerformance();

    // final String requestUrl = globals.apiMainUrl +
    //     '/api/places?latLng=${position.longitude},${position.latitude}&maxDistance=' +
    //     (_user.placesSearchDistance * 1000).toString();

    // final Map<String, String> headers = {
    //   'Authorization': token,
    //   'Content-Type': 'application/json'
    // };

    // http.Response response = await http.get(
    //   requestUrl +
    //       position.longitude.toString() +
    //       ',' +
    //       position.latitude.toString(),
    //   headers: headers,
    // );

    // final List parsedList = json.decode(response.body);

    setState(() {
      // _places = parsedList.map((s) => Place.fromJson(s)).toList();
      _loading = false;
    });
  }

  Future<List<Match>> _loadMatches(String status) async {
    setState(() {
      _loading = true;
    });

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    String requestUrl =
        globals.apiMainUrl + '/api/matches?status=${status}&&user=${_user.uid}';

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.get(
      requestUrl,
      headers: headers,
    );

    final List parsedList = json.decode(response.body);

    setState(() {
      _loading = false;
    });

    return parsedList.map((s) => Match.fromJson(s)).toList();
  }

  Future<Map<String, dynamic>> _loadPlayerPerformance() async {
    setState(() {
      _loading = true;
    });

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    String requestUrl = globals.apiMainUrl + '/api/matches/player/${_user.uid}';

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.get(
      requestUrl,
      headers: headers,
    );

    final Map<String, dynamic> performance = json.decode(response.body);

    setState(() {
      _loading = false;
    });

    return performance;
  }

  @override
  void initState() {
    loadHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Home'),
      body: _loading
          ? Loading(noBackground: true)
          : Container(
              padding: EdgeInsets.all(8),
              height: double.infinity,
              width: double.infinity,
              color: Colors.grey[100],
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.3),
                            blurRadius: 3,
                            spreadRadius: 0.5,
                            offset: Offset(2, 2)),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Bem vindo, ${_user.name}',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Você possui ${_pendingMatches.length} partida(s) pendente(s).',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          // width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.3),
                                  blurRadius: 3,
                                  spreadRadius: 0.5,
                                  offset: Offset(2, 2)),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Vitórias',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                _performance['wins'].toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                              (_performance['wins'] + _performance['losses']) >
                                      0
                                  ? Text(
                                      ((100 * _performance['wins']) /
                                                  (_performance['wins'] +
                                                      _performance['losses']))
                                              .toStringAsFixed(1) +
                                          '%',
                                      style: TextStyle(fontSize: 20),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(
                          // width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.3),
                                  blurRadius: 3,
                                  spreadRadius: 0.5,
                                  offset: Offset(2, 2)),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Derrotas',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                _performance['losses'].toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                              (_performance['wins'] + _performance['losses']) >
                                      0
                                  ? Text(
                                      ((100 * _performance['losses']) /
                                                  (_performance['wins'] +
                                                      _performance['losses']))
                                              .toStringAsFixed(1) +
                                          '%',
                                      style: TextStyle(fontSize: 20),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      drawer: Drawer(
        child: CustomDrawer(),
      ),
    );
  }
}
