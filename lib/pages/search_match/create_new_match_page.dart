import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:tennis_app_front/shared/loading.dart';
import 'package:http/http.dart' as http;

class CreateNewMatchPage extends StatefulWidget {
  @override
  _CreateNewMatchPageState createState() => _CreateNewMatchPageState();
}

class _CreateNewMatchPageState extends State<CreateNewMatchPage> {
  bool _loading = false;
  final AuthService _auth = AuthService();
  User _user;
  List<Place> _places;
  bool _favoritePlaces = true;
  final _formKey = GlobalKey<FormState>();
  String _status = 'no-action';
  String _errorMessage;
  final _dateTextField = TextEditingController();
  final _timeTextField = TextEditingController();
  bool _singles = true;
  bool _useDefaultPlaces = true;
  var _dateMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});

  List<String> _selectedPlaces = [];

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

  Future<int> _createMatch() async {
    setState(() {
      _loading = true;
    });
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl + '/api/matches/';

    final body = new Map<String, dynamic>();
    body['numberOfPlayers'] = _singles ? 2 : 4;
    var dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    var matchDate = dateFormat.parse(_dateTextField.text + " " + _timeTextField.text);
    body['matchDate'] = matchDate.toString();
    body['possiblePlaces'] = _selectedPlaces;

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
      appBar: AppBar(title: Text('Criar Partida')),
      body: Container(
        height: double.infinity,
        color: Colors.grey[100],
        padding: EdgeInsets.only(top: 8, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12)),
                            color: _singles
                                ? Colors.greenAccent
                                : Colors.grey[200],
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(
                            'Dois Jogadores',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _singles = true;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                            color: !_singles
                                ? Colors.greenAccent
                                : Colors.grey[200],
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(
                            'Quatro Jogadores',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _singles = false;
                          });
                        },
                      ),
                    ),
                    // VerticalDivider(),
                  ],
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _dateTextField,
                validator: (value) {
                  DateTime date = DateTime.parse(value);
                  print(date);
                  if (date.difference(DateTime.now()).inDays > 0) {
                    return null;
                  }
                  return 'Data Inválida';
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.event),
                  hintText: ('Informe a data da partida'),
                  labelText: ('Data da partida'),
                ),
                inputFormatters: <TextInputFormatter>[_dateMask],
              ),
              InkWell(
                onTap: () {
                  showTimePicker(context: context, initialTime: TimeOfDay.now())
                      .then((time) {
                    _timeTextField.text = time.format(context);
                  });
                },
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _timeTextField,
                    readOnly: true,
                    // validator: _validatePassword,
                    decoration: InputDecoration(
                      icon: Icon(Icons.timer),
                      hintText: ('Qual horário você quer jogar?'),
                      labelText: ('Horário'),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.place,
                          color: Colors.grey[600],
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'Locais',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _favoritePlaces,
                          onChanged: (value) {
                            setState(() {
                              _favoritePlaces = !_favoritePlaces;
                              _selectedPlaces = List<String>();
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
                      height: 150,
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
                                    if (_selectedPlaces
                                        .contains(_places[index].id)) {
                                      setState(() {
                                        _selectedPlaces.removeWhere(
                                            (id) => id == _places[index].id);
                                      });
                                    } else {
                                      setState(() {
                                        _selectedPlaces.add(_places[index].id);
                                      });
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 4, bottom: 4),
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
                                    width: double.infinity,
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          child: Checkbox(
                                            value: _selectedPlaces
                                                .contains(_places[index].id),
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
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16, bottom: 16),
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () async {
                    int status = await _createMatch();
                    if (status == 200) {
                      Fluttertoast.showToast(
                          msg: 'Partida Criada',
                          backgroundColor: Colors.greenAccent,
                          toastLength: Toast.LENGTH_LONG);
                    }
                  },
                  child: Text('Buscar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
