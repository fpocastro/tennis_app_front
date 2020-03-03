import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/pages/register_page.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'no-action';
  String _errorMessage;
  final _emailTextField = TextEditingController();
  final _passwordTextField = TextEditingController();

  String _validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty)
      return 'Campo e-mail nao pode estar vazio';
    else if (!regex.hasMatch(value))
      return 'Informe um e-mail valido';
    else
      return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Campo senha nao pode estar vazio';
    }
    return null;
  }

  Future<int> _login() async {
    final String requestUrl = globals.apiMainUrl + 'login';

    final body = new Map<String, dynamic>();
    body['email'] = _emailTextField.text;
    body['password'] = _passwordTextField.text;

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8'
    };

    http.Response response = await http.post(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final String token = json.decode(response.body)['Authorization'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('Authorization', token).then((_) {
        _setUserInfo();
      });
    } else {
      setState(() {
        _errorMessage = response.statusCode.toString();
      });
    }

    return response.statusCode;
  }

  void _setUserInfo() async {
    final String requestUrl =
        globals.apiMainUrl + 'api/v1/players/get_authenticated';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String authorization = prefs.getString('Authorization');

    final Map<String, String> headers = {'Authorization': authorization};

    http.Response response = await http.get(
      requestUrl,
      headers: headers,
    );

    prefs.setString('UserInfo', response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tennisbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(6, 7)),
                  ],
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: Scrollbar(child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailTextField,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            icon: Icon(Icons.email),
                            hintText: ('Informe seu e-mail'),
                            labelText: ('E-mail'),
                          ),
                        ),
                        TextFormField(
                          controller: _passwordTextField,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            hintText: ('Informe sua senha'),
                            labelText: ('Senha'),
                          ),
                          obscureText: true,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16, bottom: 16),
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              setState(() => this._status = 'loading');
                              if (_formKey.currentState.validate()) {
                                _login().then((result) {
                                  if (result == 200) {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/home');
                                  } else {
                                    setState(() => this._status = 'rejected');
                                    Fluttertoast.showToast(
                                      msg: _errorMessage,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      
                                    );
                                  }
                                });
                              }
                            },
                            child: Text('Enviar'),
                          ),
                        ),
                        InkWell(
                          child: Text('Novo por aqui? Cadastre-se'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
          ),
        ),
    );
  }
}
