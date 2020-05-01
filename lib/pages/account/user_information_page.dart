import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class UserInformationPage extends StatefulWidget {
  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
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
  var dateMask = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});

  void _getUserInfo() async {
    setState(() {
      _loading = true;
    });
    final User user = await AuthService().getCurrentUser();
    setState(() {
      _nameTextField.text = user.name;
      if (user.dateOfBirth != null) {
        _dateOfBirthTextField.text =
            DateFormat('dd/MM/yyyy').format(user.dateOfBirth);
        _dateOfBirthUnformatted = user.dateOfBirth;
      }
      if (user.height != null) {
        _heightTextField.text = user.height.toString();
      }
      if (user.weight != null) {
        _weightTextField.text = user.weight.toString();
      }
      _laterality = user.laterality;
      _backhandType = user.backhand;
      _favoriteCourt = user.court;
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

    final body = new Map<String, dynamic>();
    body['name'] = _nameTextField.text;
    body['dateOfBirth'] = _dateOfBirthUnformatted.toString();
    body['height'] = _heightTextField.text;
    body['weight'] = _weightTextField.text;
    body['laterality'] = _laterality;
    body['backhand'] = _backhandType;
    body['court'] = _favoriteCourt;

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
    super.initState();
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informações de Usuário')),
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
                    hintText: ('Informe seu nome'),
                    labelText: ('Nome'),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _dateOfBirthTextField,
                  // validator: () => return null,
                  decoration: InputDecoration(
                    hintText: ('Informe sua data de nascimento'),
                    labelText: ('Data de nascimento'),
                  ),
                  inputFormatters: <TextInputFormatter> [
                    dateMask
                  ],
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
