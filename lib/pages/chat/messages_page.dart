import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';

import 'chat_page.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<dynamic> _contacts = [];
  bool _loading = false;
  final AuthService _auth = AuthService();

  void _loadContacts() async {
    setState(() {
      _loading = true;
    });
    final String requestUrl = globals.apiMainUrl + '/api/chats/';

    final User user = await _auth.getCurrentUser();
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
      _contacts = parsedList;
      _loading = false;
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _loadContacts();

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    _loadContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Mensagens'),
      body: _loading
          ? Loading(noBackground: true)
          : Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 8, right: 8),
              color: Colors.grey[100],
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  separatorBuilder: (context, index) => Divider(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                  userId: _contacts[index]['user']['_id'],
                                )),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 35,
                            backgroundImage:
                                _contacts[index]['user']['pictureUrl'] != null
                                    ? NetworkImage(
                                        _contacts[index]['user']['pictureUrl'])
                                    : null,
                            child:
                                _contacts[index]['user']['pictureUrl'] == null
                                    ? Text(
                                        _contacts[index]['user']['name']
                                                .split(' ')
                                                .first[0] +
                                            _contacts[index]['user']['name']
                                                .split(' ')
                                                .last[0],
                                        style: TextStyle(fontSize: 22))
                                    : null,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  DateFormat('dd/MM/yyyy - hh:mm a').format(
                                      DateTime.parse(_contacts[index]
                                          ['messages'][0]['time'])),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  _contacts[index]['user']['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  //MediaQuery.of(context).size;
                                  child: Text(
                                    _contacts[index]['messages'][0]['text'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      drawer: CustomDrawer(),
    );
  }
}
