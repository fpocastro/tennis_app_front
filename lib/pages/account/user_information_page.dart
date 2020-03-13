import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/services/database.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class UserInformationPage extends StatefulWidget {
  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'no-action';
  bool _loading = false;
  String _errorMessage;
  final _nameTextField = TextEditingController();
  final _emailTextField = TextEditingController();
  final _dateOfBirthTextField = TextEditingController();
  DateTime _dateOfBirthUnformatted;
  final _heightTextField = TextEditingController();
  final _weightTextField = TextEditingController();
  String _laterality;
  String _backhandType;
  String _favoriteCourt;

  // void _getUserInfo() async {
  //   setState(() {
  //     _status = 'loading';
  //   });
  //   final String requestUrl =
  //       globals.apiMainUrl + 'api/v1/players/get_authenticated';

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String authorization = prefs.getString('Authorization');

  //   final Map<String, String> headers = {'Authorization': authorization};

  //   http.Response response = await http.get(
  //     requestUrl,
  //     headers: headers,
  //   );

  //   var userInfo = json.decode(response.body);
  //   setState(() {
  //     _nameTextField.text = userInfo['name'];
  //     _emailTextField.text = userInfo['email'];
  //     _dateOfBirthTextField.text = userInfo['dateOfBirth'];
  //     _heightTextField.text = userInfo['height'];
  //     _weightTextField.text = userInfo['weight'];
  //     _laterality = userInfo['laterality'];
  //     _backhandType = userInfo['backhand'];
  //     _favoriteCourt = userInfo['court'];
  //     _status = 'ok';
  //   });
  // }

  void _getUserInfo() async {
    setState(() {
      _loading = true;
    });
    final FirebaseUser user = await AuthService().getCurrentUser();
    final dynamic userInfo = await DatabaseService(uid: user.uid).getUserData();
    setState(() {
      _nameTextField.text = userInfo['name'];
      if (userInfo['dateOfBirth'] != null) {
        _dateOfBirthTextField.text = DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(userInfo['dateOfBirth'],
                isUtc: true));
        _dateOfBirthUnformatted =
            DateTime.fromMillisecondsSinceEpoch(userInfo['dateOfBirth']);
      }
      if (userInfo['height'] != null) {
        _heightTextField.text = userInfo['height'].toString();
      }
      if (userInfo['weight'] != null) {
        _weightTextField.text = userInfo['weight'].toString();
      }
      _laterality = userInfo['laterality'];
      _backhandType = userInfo['backhand'];
      _favoriteCourt = userInfo['court'];
      _loading = false;
    });
  }

  void _setUserInfo() async {
    setState(() {
      _loading = true;
    });
    final FirebaseUser user = await AuthService().getCurrentUser();
    await DatabaseService(uid: user.uid).updateUserData(
        _nameTextField.text,
        _dateOfBirthUnformatted.toUtc().millisecondsSinceEpoch,
        int.parse(_heightTextField.text),
        int.parse(_weightTextField.text),
        _laterality,
        _backhandType,
        _favoriteCourt);
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informações de Usuário')),
      body: Container(
        padding: EdgeInsets.only(top: 8, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Form(
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
                        hintText: ('Informe seu nome'),
                        labelText: ('Nome'),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final DateTime _now = DateTime.now();
                        showDatePicker(
                          context: context,
                          initialDate: _now,
                          firstDate: DateTime(1900),
                          lastDate: _now,
                        ).then((date) {
                          setState(() {
                            _dateOfBirthUnformatted = date;
                            _dateOfBirthTextField.text =
                                DateFormat('dd/MM/yyyy').format(date);
                          });
                        });
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dateOfBirthTextField,
                          // validator: () => return null,
                          decoration: InputDecoration(
                            hintText: ('Informe sua data de nascimento'),
                            labelText: ('Data de nascimento'),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _heightTextField,
                      validator: (value) {
                        return null;
                      },
                      decoration: InputDecoration(
                        // icon: Icon(Icons.),
                        hintText: ('Informe sua altura (cm)'),
                        labelText: ('Altura (cm)'),
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _weightTextField,
                      validator: (value) {
                        return null;
                      },
                      decoration: InputDecoration(
                        // icon: Icon(Icons.),
                        hintText: ('Informe seu peso (kg)'),
                        labelText: ('Peso (kg)'),
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _laterality,
                      decoration: InputDecoration(
                        hintText: 'Lateralidade',
                      ),
                      items: <List<String>>[
                        [null, ''],
                        ['1', 'Destro'],
                        ['2', 'Canhoto'],
                      ].map((List<String> value) {
                        return DropdownMenuItem<String>(
                          value: value[1],
                          child: Text(value[1]),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          _laterality = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _backhandType,
                      decoration: InputDecoration(
                        hintText: 'Backhand',
                      ),
                      items: <List<String>>[
                        [null, ''],
                        ['1', 'Uma mão'],
                        ['2', 'Duas mãos'],
                      ].map((List<String> value) {
                        return DropdownMenuItem<String>(
                          value: value[1],
                          child: Text(value[1]),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          _backhandType = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _favoriteCourt,
                      decoration: InputDecoration(
                        hintText: 'Quadra favorita',
                      ),
                      items: <List<String>>[
                        [null, ''],
                        ['1', 'Saibro'],
                        ['2', 'Rápida'],
                      ].map((List<String> value) {
                        return DropdownMenuItem<String>(
                          value: value[1],
                          child: Text(value[1]),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          _favoriteCourt = value;
                        });
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 16),
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                try {
                                  await _setUserInfo();
                                  Fluttertoast.showToast(
                                      msg: 'Dados Atualizados',
                                      backgroundColor: Colors.red,
                                      toastLength: Toast.LENGTH_LONG);
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
            ],
          ),
        ),
      ),
    );
  }
}
