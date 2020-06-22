import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_app_front/models/match.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/places/place_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:tennis_app_front/shared/loading.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

import 'match_page.dart';

class MatchesPage extends StatefulWidget {
  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  bool _loading = false;
  String _status = 'open';
  List<Match> _matches = [];
  final AuthService _auth = AuthService();
  User _user;

  void _loadMatches() async {
    setState(() {
      _loading = true;
    });

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    String requestUrl = globals.apiMainUrl +
        '/api/matches?status=${_status}&&user=${_user.uid}';

    if (_status == 'open') {
      requestUrl += '&matchDate=${DateTime.now().toString()}';
    }

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
      _matches = parsedList.map((s) => Match.fromJson(s)).toList();
      _loading = false;
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _loadMatches();

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    _loadMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Minhas Partidas'),
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
                    child: Text('Aberta'),
                    color: _status == 'open' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'open') {
                              setState(() {
                                _status = 'open';
                              });
                              _loadMatches();
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text('Pendente'),
                    color: _status == 'pending' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'pending') {
                              setState(() {
                                _status = 'pending';
                              });
                              _loadMatches();
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text('Finalizada'),
                    color: _status == 'closed' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'closed') {
                              setState(() {
                                _status = 'closed';
                              });
                              _loadMatches();
                            }
                          },
                  ),
                ],
              ),
            ),
            _loading
                ? Expanded(child: Center(child: Loading(noBackground: true)))
                : _matches.length == 0
                    ? Expanded(
                        child: Center(
                            child: Text(
                        'Nenhuma partida encontrada',
                        style: TextStyle(fontSize: 16),
                      )))
                    : Expanded(
                        child: Container(
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _matches.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MatchPage(
                                              match: _matches[index],
                                            )),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(top: 8, bottom: 8),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              (_matches[index]
                                                          .numberOfPlayers ==
                                                      2
                                                  ? 'Simples'
                                                  : 'Duplas'),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                                ' - ${new DateFormat('dd/MM/yyyy - hh:mm a').format(_matches[index].matchDate)}')
                                          ],
                                        ),
                                        Divider(thickness: 1),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'Equipe 1',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              'Equipe 2',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: <Widget>[
                                            UserImageWidget(
                                              user: _matches[index].creator,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(_matches[index]
                                                        .creator
                                                        .name),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Divider(),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: _matches[index]
                                                                .teamTwo
                                                                .length >
                                                            0
                                                        ? Text(_matches[index]
                                                            .teamTwo[0]
                                                            .name)
                                                        : Text(
                                                            'Aguardando Jogador',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blueAccent)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            _matches[index].teamTwo.length > 0
                                                ? UserImageWidget(
                                                    user: _matches[index]
                                                        .teamTwo[0],
                                                  )
                                                : CircleAvatar(
                                                    radius: 25,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 30,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              _matches[index].numberOfPlayers !=
                                                      2
                                                  ? 8
                                                  : 0,
                                        ),
                                        _matches[index].numberOfPlayers != 2
                                            ? Row(
                                                children: <Widget>[
                                                  _matches[index]
                                                              .teamOne
                                                              .length >
                                                          1
                                                      ? UserImageWidget(
                                                          user: _matches[index]
                                                              .teamOne[1],
                                                        )
                                                      : CircleAvatar(
                                                          radius: 25,
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 30,
                                                          ),
                                                        ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: _matches[index]
                                                                      .teamOne
                                                                      .length >
                                                                  1
                                                              ? Text(_matches[
                                                                      index]
                                                                  .teamOne[1]
                                                                  .name)
                                                              : Text(
                                                                  'Aguardando Jogador',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blueAccent)),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Divider(),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: _matches[index]
                                                                      .teamTwo
                                                                      .length >
                                                                  1
                                                              ? Text(_matches[
                                                                      index]
                                                                  .teamTwo[1]
                                                                  .name)
                                                              : Text(
                                                                  'Aguardando Jogador',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blueAccent)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  _matches[index]
                                                              .teamTwo
                                                              .length >
                                                          1
                                                      ? UserImageWidget(
                                                          user: _matches[index]
                                                              .teamTwo[1],
                                                        )
                                                      : CircleAvatar(
                                                          radius: 25,
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 30,
                                                          ),
                                                        ),
                                                ],
                                              )
                                            : Container(),
                                        Divider(
                                          thickness: 1,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Locais',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minHeight: 50, maxHeight: 100),
                                          child: ListView.separated(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.only(
                                                  top: 4, bottom: 4),
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                        height: 4,
                                                      ),
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              itemCount: _matches[index]
                                                  .possiblePlaces
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int placeIndex) {
                                                return Text(
                                                  _matches[index]
                                                      .possiblePlaces[
                                                          placeIndex]
                                                      .name,
                                                );
                                              }),
                                        )
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

class UserImageWidget extends StatelessWidget {
  final User user;

  const UserImageWidget({
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: 25,
        backgroundImage:
            user.pictureUrl != null ? NetworkImage(user.pictureUrl) : null,
        child: user.pictureUrl == null
            ? Text(user.name.split(' ').first[0] + user.name.split(' ').last[0],
                style: TextStyle(fontSize: 22))
            : null);
  }
}
