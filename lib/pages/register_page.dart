import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tennis_app_front/shared/globals.dart' as globals;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'no-action';
  final _nameTextField = TextEditingController();
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

  Future<int> _register() async {
    final String requestUrl = globals.apiMainUrl + 'signup';

    final body = new Map<String, dynamic>();

    body['name'] = _nameTextField.text;
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

    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Register'),
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
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameTextField,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Campo nome nao pode estar vazio';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: ('Informe seu nome'),
                          labelText: ('Nome'),
                        ),
                      ),
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
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Campo senha nao pode estar vazio';
                          }
                          return null;
                        },
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
                              _register().then((result) {
                                if (result == 200) {
                                  Navigator.of(context).pop();
                                } else {
                                  setState(() => this._status = 'rejected');
                                }
                              });
                            }
                          },
                          child: Text('Enviar'),
                        ),
                      ),
                      InkWell(
                        child: Text('Ja possui uma conta? Acesse-a'),
                        onTap: () => Navigator.pop(context),
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
