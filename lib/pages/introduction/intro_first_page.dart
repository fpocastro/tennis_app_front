import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/introduction/intro_level_page.dart';
import 'package:tennis_app_front/pages/introduction/intro_second_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class IntroFirstPage extends StatefulWidget {
  @override
  _IntroFirstPageState createState() => _IntroFirstPageState();
}

class _IntroFirstPageState extends State<IntroFirstPage> {
  String _errorMessage;
  bool _loading = false;
  final AuthService _auth = AuthService();

  Future<int> updateUserLastLocation(double lat, double lng) async {
    setState(() {
      _loading = true;
    });
    final User user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl + '/api/users/' + user.uid;

    var body = user.toJsonRequest();
    body['lastLocation'] = {
      'type': 'Point',
      'coordinates': [lng, lat]
    };

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    print(response.body);

    setState(() {
      _loading = false;
    });

    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 16, right: 16, top: 64),
        color: Colors.orange[100],
        child: Column(
          children: <Widget>[
            Text(
              'Bem Vindo ao TennisApp!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Você está a alguns passos de finalizar a criação da sua conta!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 32,
            ),
            Text(
              'É necessário que você habilite a localização geográfica do seu dispositivo. Sua localização é utilizada em várias funcionalidades do aplicativo.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8,
            ),
            RaisedButton(
              child: Text('Ativar Localização'),
              color: Colors.orange[300],
              onPressed: () async {
                try {
                  Position position = await Geolocator().getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  int statusCode = await updateUserLastLocation(
                      position.latitude, position.longitude);
                  if (statusCode == 200) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IntroLevelPage()));
                  } else {
                    setState(() {
                      _errorMessage =
                          'Ocorreu um erro ao atualizar sua localização.';
                    });
                  }
                } on PlatformException catch (e) {
                  String message = '';
                  if (e.code == 'PERMISSION_DENIED') {
                    message =
                        'Por favor, habilite a localização geografica nas configurações do dispositivo.';
                  } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
                    message =
                        'Por favor, habilite a localização geografica nas configurações do dispositivo.';
                  }
                  setState(() {
                    _errorMessage = message;
                  });
                }
              },
            ),
            SizedBox(
              height: 8,
            ),
            _errorMessage != null
                ? Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red[200],
                        border: Border.all(color: Colors.red[500]),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Text(_errorMessage))
                : Container(),
          ],
        ),
      ),
    );
  }
}
