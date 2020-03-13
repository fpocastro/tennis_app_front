import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/services/auth.dart';
import 'dart:convert';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:tennis_app_front/shared/loading.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _status = 'no-action';
  bool _loading = false;
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
    return _loading ? Loading() : Scaffold(
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
                        keyboardType: TextInputType.emailAddress,
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
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() => this._loading = true);
                              dynamic result = await _auth.registerWithEmailAndPassword(_emailTextField.text, _passwordTextField.text, _nameTextField.text);
                              Navigator.popUntil(context, ModalRoute.withName('/'));
                              if (result == null) {
                                setState(() => this._status = 'error');
                                setState(() => this._loading = false);
                              }
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
