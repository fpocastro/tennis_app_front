import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';
import 'package:tennis_app_front/services/auth.dart';

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class Question {
  String id;
  String question;
  String answer;

  Question.fromJson(Map<String, dynamic> data) {
    id = data['_id'];
    question = data['question'];
    answer = data['answer'];
  }
}

class _FaqPageState extends State<FaqPage> {
  final AuthService _auth = AuthService();
  bool _loading = false;
  List<dynamic> _questions = [];

  void _setQuestions() async {
    setState(() => _loading = true);
    String requestUrl = globals.apiMainUrl + '/api/faqs/';

    String _token = await _auth.getAuthorizationToken();

    final Map<String, String> headers = {
      'Authorization': _token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.get(
      requestUrl,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var questions = json.decode(response.body);
      setState(() {
        _questions =
            questions.map((message) => new Question.fromJson(message)).toList();
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _setQuestions();

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    _setQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perguntas Frequentes')),
      body: _loading
          ? Loading(noBackground: true)
          : Container(
              padding: EdgeInsets.only(bottom: 16, left: 8, right: 8),
              color: Colors.grey[100],
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 8,
                    );
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[200],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            _questions[index].question,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            _questions[index].answer,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
