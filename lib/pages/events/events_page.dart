import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/event.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/events/create_event_page.dart';
import 'package:tennis_app_front/pages/events/event_page.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/loading.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _loading = false;
  String _status = 'creator';
  List<Event> _events = [];
  final AuthService _auth = AuthService();
  User _user;

  void _loadEvents() async {
    setState(() {
      _loading = true;
    });

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    String requestUrl = globals.apiMainUrl + '/api/events?searchBy=${_status}';

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
      _events = parsedList.map((s) => Event.fromJson(s)).toList();
      _loading = false;
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _loadEvents();

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    _loadEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Eventos'),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateEventPage()));
        },
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.grey[400],
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Autorais'),
                    color: _status == 'creator' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'creator') {
                              setState(() {
                                _status = 'creator';
                              });
                              _loadEvents();
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text('Participando'),
                    color: _status == 'participant' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'participant') {
                              setState(() {
                                _status = 'participant';
                              });
                              _loadEvents();
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text('Finalizados'),
                    color: _status == 'closed' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'closed') {
                              setState(() {
                                _status = 'closed';
                              });
                              _loadEvents();
                            }
                          },
                  ),
                ],
              ),
            ),
            _loading
                ? Expanded(child: Center(child: Loading(noBackground: true)))
                : _events.length == 0
                    ? Expanded(
                        child: Center(
                            child: Text(
                        'Nenhum evento encontrado',
                        style: TextStyle(fontSize: 16),
                      )))
                    : Expanded(
                        child: Container(
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _events.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EventPage(
                                              event: _events[index],
                                            )),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(8),
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
                                    child: Column(
                                      children: <Widget>[
                                        Text(_events[index].name,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                'Organizador: ${_events[index].creator.name}')),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                'Localização: ${_events[index].place.name}')),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
      drawer: Drawer(
        child: CustomDrawer(),
      ),
    );
  }
}
