import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/loading.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  bool _loading = true;
  final AuthService _auth = AuthService();
  User _user;
  final _formKey = GlobalKey<FormState>();
  final _nameTextField = TextEditingController();
  List<Place> _places;
  bool _favoritePlaces = true;
  String _selectedPlace;

  void _getClosestPlaces() async {
    setState(() {
      _loading = true;
    });
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/places?latLng=${position.longitude},${position.latitude}&maxDistance=' +
        (_user.placesSearchDistance * 1000).toString();

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.get(
      requestUrl +
          position.longitude.toString() +
          ',' +
          position.latitude.toString(),
      headers: headers,
    );

    final List parsedList = json.decode(response.body);

    setState(() {
      _places = parsedList.map((s) => Place.fromJson(s)).toList();
      _loading = false;
    });
  }

  void _getFavoritPlaces() async {
    setState(() {
      _loading = true;
    });
    final String requestUrl = globals.apiMainUrl + '/api/users/places';

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

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
      _places = parsedList.map((s) => Place.fromJson(s)).toList();
      _loading = false;
    });
  }

  Future<int> _createEvent() async {
    setState(() {
      _loading = true;
    });
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl + '/api/events/';

    final body = new Map<String, dynamic>();
    body['name'] = _nameTextField.text;
    body['place'] = _selectedPlace;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.post(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    setState(() {
      _loading = false;
    });

    return response.statusCode;
  }

  @override
  void initState() {
    _getFavoritPlaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Evento'),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.grey[100],
        padding: EdgeInsets.only(top: 8, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameTextField,
                  validator: (value) {
                    return null;
                  },
                  decoration: InputDecoration(
                    // icon: Icon(Icons.),
                    hintText: ('Informe o nome do evento'),
                    labelText: ('Nome'),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Selecione o local',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _favoritePlaces,
                            onChanged: (value) {
                              setState(() {
                                _favoritePlaces = !_favoritePlaces;
                                _selectedPlace = null;
                              });
                              if (_favoritePlaces) {
                                _getFavoritPlaces();
                              } else {
                                _getClosestPlaces();
                              }
                            },
                          ),
                          Text('Favoritos'),
                        ],
                      ),
                      Container(
                        height: 250,
                        // padding: EdgeInsets.only(
                        //   right: 16,
                        //   left: 16,
                        // ),
                        decoration: BoxDecoration(
                            border: Border(
                          top: BorderSide(width: 1, color: Colors.grey[500]),
                          bottom: BorderSide(width: 1, color: Colors.grey[500]),
                        )),
                        child: _loading
                            ? Loading(
                                noBackground: true,
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _places.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPlace = _places[index].id;
                                      });
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(top: 4, bottom: 4),
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.3),
                                              blurRadius: 3,
                                              spreadRadius: 0.5,
                                              offset: Offset(2, 2)),
                                        ],
                                      ),
                                      width: double.infinity,
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(
                                            child: Checkbox(
                                              value: _selectedPlace ==
                                                  _places[index].id,
                                              onChanged: (value) {},
                                            ),
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Flexible(
                                            child: Text(
                                              _places[index].name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16, bottom: 16),
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () async {
                            int status = await _createEvent();
                            if (status == 200) {
                              // Fluttertoast.showToast(
                              //     msg: 'Partida Criada',
                              //     backgroundColor: Colors.greenAccent,
                              //     toastLength: Toast.LENGTH_LONG);
                            }
                          },
                          child: Text('Criar Evento'),
                        ),
                      ),
                    ],
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
