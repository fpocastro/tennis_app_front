import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class AccountConfigurationPage extends StatefulWidget {
  @override
  _AccountConfigurationPageState createState() =>
      _AccountConfigurationPageState();
}

class _AccountConfigurationPageState extends State<AccountConfigurationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool _loading = false;

  int _playersSearchDistance;
  int _placesSearchDistance;
  double _playerLevel;

  void _getUserInfo() async {
    setState(() {
      _loading = true;
    });
    final User user = await _auth.getCurrentUser();
    setState(() {
      _playersSearchDistance = user.playersSearchDistance;
      _placesSearchDistance = user.placesSearchDistance;
      _playerLevel = user.level;
      _loading = false;
    });
  }

  void _setUserInfo() async {
    setState(() {
      _loading = true;
    });
    final User user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl + '/api/users/' + user.uid;

    var body = user.toJsonRequest();
    body['playersSearchDistance'] = _playersSearchDistance;
    body['placesSearchDistance'] = _placesSearchDistance;
    body['level'] = _playerLevel;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    if (response.statusCode == 200) {
      await _auth.setCurrentUser(response.body);
      Fluttertoast.showToast(
          msg: 'Dados Atualizados',
          backgroundColor: Colors.greenAccent,
          toastLength: Toast.LENGTH_LONG);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurações da Conta')),
      body: Container(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        height: double.infinity,
        color: Colors.grey[100],
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Distância máxima de busca (km)',
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Jogadores',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: Text(_playersSearchDistance.toString() + ' km'),
                    ),
                    Expanded(
                      child: Slider(
                        min: 5.0,
                        max: 100.0,
                        value: _playersSearchDistance != null
                            ? _playersSearchDistance.toDouble()
                            : 5,
                        divisions: 100,
                        onChanged: (double value) {
                          setState(() {
                            _playersSearchDistance = value.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Locais',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: Text(_placesSearchDistance.toString() + ' km'),
                    ),
                    Expanded(
                      child: Slider(
                        min: 5.0,
                        max: 100.0,
                        value: _placesSearchDistance != null
                            ? _placesSearchDistance.toDouble()
                            : 5,
                        divisions: 100,
                        onChanged: (double value) {
                          setState(() {
                            _placesSearchDistance = value.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nível base de jogo',
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: Text(_playerLevel.toString()),
                    ),
                    Expanded(
                      child: Slider(
                        min: 1.5,
                        max: 5.5,
                        divisions: 8,
                        value: _playerLevel != null ? _playerLevel : 1.5,
                        onChanged: (double value) {
                          setState(() {
                            _playerLevel = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16),
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            try {
                              _setUserInfo();
                            } catch (e) {
                              print(e);
                            }
                          },
                    child: Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
