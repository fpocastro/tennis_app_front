import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/event.dart';
import 'package:tennis_app_front/models/event_round.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/events/event_manage_matches.dart';
import 'package:tennis_app_front/shared/loading.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class EventManageRounds extends StatefulWidget {
  final Event event;
  final String groupId;

  const EventManageRounds({Key key, this.event, this.groupId})
      : super(key: key);

  @override
  _EventManageRoundsState createState() => _EventManageRoundsState();
}

class _EventManageRoundsState extends State<EventManageRounds> {
  bool _loading = false;
  final AuthService _auth = AuthService();
  User _user;
  final _nameTextField = TextEditingController();

  Future<String> _addRound() async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/events/' +
        widget.event.id +
        '/group/' +
        widget.groupId +
        '/add_round';

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    final body = new Map<String, dynamic>();
    body['name'] = _nameTextField.text;

    http.Response response = await http.put(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    setState(() {
      _loading = false;
    });

    return response.statusCode == 200
        ? json.decode(response.body)['eventId']
        : null;
  }

  Future<int> _removeRound(String roundId) async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/events/' +
        widget.event.id +
        '/group/' +
        widget.groupId +
        '/round/' +
        roundId;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.delete(
      requestUrl,
      headers: headers,
    );

    setState(() {
      _loading = false;
    });

    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Rodadas'),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _nameTextField,
                    validator: (value) {
                      return null;
                    },
                    decoration: InputDecoration(
                      // icon: Icon(Icons.),
                      hintText: ('Informe o nome da rodada'),
                      labelText: ('Nova rodada'),
                    ),
                  ),
                  SizedBox(height: 16),
                  RaisedButton(
                    color: Colors.greenAccent,
                    child: Text('Adicionar'),
                    onPressed: () async {
                      String response = await _addRound();
                      if (response != null) {
                        setState(() {
                          widget.event.groups
                              .firstWhere((group) => group.id == widget.groupId)
                              .rounds
                              .add(new EventRound.fromJson({
                                '_id': response,
                                'name': _nameTextField.text,
                                'matches': []
                              }));
                          _nameTextField.text = '';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? Center(child: Loading(noBackground: true))
                  : Container(
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: 16),
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 16,
                          );
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: widget.event.groups
                            .firstWhere((group) => group.id == widget.groupId)
                            .rounds
                            .length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventManageMatches(
                                        round: widget.event.groups
                                            .firstWhere((group) =>
                                                group.id == widget.groupId)
                                            .rounds[index],
                                        participants: widget.event.participants,
                                        eventId: widget.event.id,
                                        groupId: widget.groupId,
                                        placeId: widget.event.place.id,
                                      )),
                            ),
                            child: Container(
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
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      int response = await _removeRound(widget
                                          .event.groups
                                          .firstWhere((group) =>
                                              group.id == widget.groupId)
                                          .rounds[index]
                                          .id);
                                      if (response == 200) {
                                        setState(() {
                                          widget.event.groups
                                              .firstWhere((group) =>
                                                  group.id == widget.groupId)
                                              .rounds
                                              .removeAt(index);
                                        });
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.event.groups
                                          .firstWhere((group) =>
                                              group.id == widget.groupId)
                                          .rounds[index]
                                          .name,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  Icon(Icons.more_vert),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
