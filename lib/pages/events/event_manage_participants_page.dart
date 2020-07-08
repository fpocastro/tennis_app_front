import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tennis_app_front/models/event.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/players/player_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';

class EventManageParticipantsPage extends StatefulWidget {
  final Event event;

  const EventManageParticipantsPage({Key key, this.event}) : super(key: key);

  @override
  _EventManageParticipantsPageState createState() =>
      _EventManageParticipantsPageState();
}

class _EventManageParticipantsPageState
    extends State<EventManageParticipantsPage> {
  bool _loading = true;
  final AuthService _auth = AuthService();
  User _user;
  final _nameTextField = TextEditingController();
  List<User> _players = [];

  void _loadUser() async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    setState(() {
      _loading = false;
    });
  }

  void _loadPlayers() async {
    setState(() {
      _loading = true;
    });

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/users?latLng=${position.longitude},${position.latitude}&maxDistance=' +
        (_user.playersSearchDistance * 1000).toString() +
        '&name=${_nameTextField.text}';

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
      if (_nameTextField.text != '') {
        _players = parsedList.map((s) => User.fromJson(s)).toList();
      }
      _loading = false;
    });
  }

  Future<int> addPlayer(String participantId) async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/events/' +
        widget.event.id +
        '/add_participant/' +
        participantId;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      headers: headers,
    );

    setState(() {
      _loading = false;
    });

    return response.statusCode;
  }

  Future<int> removePlayer(String participantId) async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/events/' +
        widget.event.id +
        '/remove_participant/' +
        participantId;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      headers: headers,
    );

    setState(() {
      _loading = false;
    });

    return response.statusCode;
  }

  @override
  void initState() {
    setState(() {
      _players = widget.event.participants;
    });
    _loadUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Participantes'),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameTextField,
              validator: (value) {
                return null;
              },
              decoration: InputDecoration(
                // icon: Icon(Icons.),
                hintText: ('Informe o nome do jogador'),
                labelText: ('Buscar jogador'),
              ),
              onChanged: (value) {
                if (value == '') {
                  setState(() {
                    _players = widget.event.participants;
                    _loading = false;
                  });
                } else {
                  _loadPlayers();
                }
              },
            ),
            Expanded(
              child: _loading
                  ? Center(child: Loading(noBackground: true))
                  : Container(
                      margin: EdgeInsets.only(left: 8, right: 8),
                      child: ListView.separated(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _players.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
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
                                Container(
                                  child: (widget.event.participants.singleWhere(
                                              (player) =>
                                                  player.uid ==
                                                  _players[index].uid,
                                              orElse: () => null)) !=
                                          null
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            int response = await removePlayer(_players[index].uid);
                                            if (response == 200) {
                                              setState(() {
                                                widget.event.participants.removeWhere((player) => player.uid == _players[index].uid);
                                              });
                                            }
                                          },
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: Colors.greenAccent,
                                          ),
                                          onPressed: () async {
                                            int response = await addPlayer(_players[index].uid);
                                            if (response == 200) {
                                              setState(() {
                                                widget.event.participants.add(_players[index]);
                                              });
                                            }
                                          },
                                        ),
                                ),
                                GestureDetector(
                                    onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PlayerPage(
                                                    player: _players[index],
                                                  )),
                                        ),
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 35,
                                          backgroundImage: _players[index]
                                                      .pictureUrl !=
                                                  null
                                              ? NetworkImage(
                                                  _players[index].pictureUrl)
                                              : null,
                                          child: _players[index].pictureUrl ==
                                                  null
                                              ? Text(
                                                  _players[index]
                                                          .name
                                                          .split(' ')
                                                          .first[0] +
                                                      _players[index]
                                                          .name
                                                          .split(' ')
                                                          .last[0],
                                                  style:
                                                      TextStyle(fontSize: 22))
                                              : null,
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _players[index].name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              _players[index].level != null
                                                  ? 'Nível ${_players[index].level.toStringAsFixed(1)}'
                                                  : '',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
