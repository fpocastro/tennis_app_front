import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tennis_app_front/models/match.dart';
import 'package:tennis_app_front/models/match_set.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/places/place_page.dart';
import 'package:tennis_app_front/pages/players/player_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';

class MatchPage extends StatefulWidget {
  final Match match;

  const MatchPage({Key key, this.match}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  bool _loading = true;
  final AuthService _auth = AuthService();
  User _user;
  bool _isInMatch = false;
  int _userTeam;

  Future<bool> setIsInMatch() async {
    _user = await _auth.getCurrentUser();
    for (User user in widget.match.teamOne) {
      if (user.uid == _user.uid) {
        setState(() {
          _isInMatch = true;
          _userTeam = 1;
        });
        return true;
      }
    }
    for (User user in widget.match.teamTwo) {
      if (user.uid == _user.uid) {
        setState(() {
          _isInMatch = true;
          _userTeam = 2;
        });
        return true;
      }
    }
    return false;
  }

  Future<int> _joinMatch(int team) async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/matches/' +
        widget.match.id +
        '/join/' +
        team.toString();
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

  void _quitMatch() async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl =
        globals.apiMainUrl + '/api/matches/' + widget.match.id + '/quit';
    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.match.teamOne.removeWhere((user) => user.uid == _user.uid);
        widget.match.teamTwo.removeWhere((user) => user.uid == _user.uid);
        _isInMatch = false;
        _userTeam = null;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  void _deleteMatch() async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl =
        globals.apiMainUrl + '/api/matches/' + widget.match.id;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.delete(
      requestUrl,
      headers: headers,
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    }

    setState(() {
      _loading = false;
    });
  }

  void reload() {
    setState(() {});
  }

  @override
  void initState() {
    setIsInMatch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descrição da Partida'),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.only(left: 8, right: 8),
        width: double.infinity,
        height: double.infinity,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                widget.match.private
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _isInMatch &&
                                  ['Aberta', 'Em andamento']
                                      .contains(widget.match.status)
                              ? RaisedButton(
                                  color: Colors.red,
                                  child: Text(
                                      widget.match.creator.uid == _user.uid
                                          ? 'Excluir'
                                          : 'Abandonar'),
                                  onPressed: () async {
                                    if (widget.match.creator.uid == _user.uid) {
                                      _deleteMatch();
                                    } else {
                                      _quitMatch();
                                    }
                                  },
                                )
                              : Container(),
                          _isInMatch &&
                                  widget.match.creator.uid == _user.uid &&
                                  widget.match.status == 'Em andamento'
                              ? RaisedButton(
                                  color: Colors.greenAccent,
                                  child: Text('Definir Resultado'),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      child: Dialog(
                                        child: SetResultWidget(
                                          match: widget.match,
                                          notify: reload,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(),
                        ],
                      ),
                Text('Equipe 1',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 70, maxHeight: 148),
                  child: MatchPlayersWidget(
                    users: widget.match.teamOne,
                  ),
                ),
                !_isInMatch &&
                        widget.match.numberOfPlayers != 2 &&
                        widget.match.teamOne.length < 2
                    ? RaisedButton(
                        color: Colors.greenAccent,
                        child: Text('Entrar'),
                        onPressed: () async {
                          int response = await _joinMatch(1);
                          if (response == 200) {
                            setState(() {
                              widget.match.teamOne.add(_user);
                              _isInMatch = true;
                              _userTeam = 1;
                            });
                          }
                        },
                      )
                    : Container(),
                SizedBox(height: 16),
                Text('Equipe 2',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 16),
                widget.match.teamTwo.length > 0
                    ? ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: 70, maxHeight: 148),
                        child: MatchPlayersWidget(
                          users: widget.match.teamTwo,
                        ),
                      )
                    : Container(),
                !_isInMatch &&
                        (widget.match.teamTwo.length == 0 ||
                            (widget.match.teamTwo.length == 1 &&
                                widget.match.numberOfPlayers != 2))
                    ? RaisedButton(
                        color: Colors.greenAccent,
                        child: Text('Entrar'),
                        onPressed: () async {
                          int response = await _joinMatch(2);
                          if (response == 200) {
                            setState(() {
                              widget.match.teamTwo.add(_user);
                              _isInMatch = true;
                              _userTeam = 2;
                            });
                          }
                        },
                      )
                    : Container(),
                widget.match.sets.length > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 16),
                          Text('Resultado',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Row(
                            children: <Widget>[
                              MatchSetDisplayWidget(
                                teamOne: widget.match.sets[0].teamOne,
                                teamOneTiebreak:
                                    widget.match.sets[0].teamOneTiebreak,
                                teamTwo: widget.match.sets[0].teamTwo,
                                teamTwoTiebreak:
                                    widget.match.sets[0].teamTwoTiebreak,
                              ),
                              SizedBox(width: 16),
                              widget.match.sets.length > 1
                                  ? MatchSetDisplayWidget(
                                      teamOne: widget.match.sets[1].teamOne,
                                      teamOneTiebreak:
                                          widget.match.sets[1].teamOneTiebreak,
                                      teamTwo: widget.match.sets[1].teamTwo,
                                      teamTwoTiebreak:
                                          widget.match.sets[1].teamTwoTiebreak,
                                    )
                                  : Container(),
                              SizedBox(width: 16),
                              widget.match.sets.length > 2
                                  ? MatchSetDisplayWidget(
                                      teamOne: widget.match.sets[2].teamOne,
                                      teamOneTiebreak:
                                          widget.match.sets[2].teamOneTiebreak,
                                      teamTwo: widget.match.sets[2].teamTwo,
                                      teamTwoTiebreak:
                                          widget.match.sets[2].teamTwoTiebreak,
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(height: 16),
                Text('Informações',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Divider(
                  thickness: 1,
                ),
                SizedBox(height: 10),
                MatchInfoItem(
                    title: 'Solicitante', value: widget.match.creator.name),
                MatchInfoItem(title: 'Status', value: widget.match.status),
                MatchInfoItem(
                    title: 'Tipo',
                    value: widget.match.numberOfPlayers == 2
                        ? 'Simples'
                        : 'Duplas'),
                MatchInfoItem(
                    title: 'Data',
                    value: new DateFormat('dd/MM/yyyy - hh:mm a')
                        .format(widget.match.matchDate)),
                Text('Locais Possíveis',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 70, maxHeight: 160),
                  child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      separatorBuilder: (context, index) => Divider(),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: widget.match.possiblePlaces.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlacePage(
                                      place: widget.match.possiblePlaces[index],
                                    )),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.match.possiblePlaces[index].name,
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                              Text(
                                widget.match.possiblePlaces[index].fullAddress,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MatchPlayersWidget extends StatelessWidget {
  final List<User> users;

  const MatchPlayersWidget({
    @required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(
        height: 8,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlayerPage(
                      player: users[index],
                    )),
          ),
          child: Container(
            width: double.infinity,
            height: 70,
            child: Row(
              children: <Widget>[
                Container(
                  width: 70,
                  height: double.infinity,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          blurRadius: 3,
                          spreadRadius: 0.5,
                          offset: Offset(2, 2)),
                    ],
                    image: (users[index].pictureUrl != null)
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: new NetworkImage(users[index].pictureUrl),
                          )
                        : null,
                  ),
                  child: (users[index].pictureUrl == null)
                      ? Center(
                          child: Text(
                            users[index].name.split(' ').first[0] +
                                users[index].name.split(' ').last[0],
                            style: TextStyle(fontSize: 22),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          users[index].name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Nível ${users[index].level.toString()}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MatchInfoItem extends StatelessWidget {
  final String title;
  final String value;

  const MatchInfoItem({
    @required this.title,
    @required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(value),
            ],
          ),
        ),
        Divider(
          height: 36,
          thickness: 1,
        ),
      ],
    );
  }
}

class SetResultWidget extends StatefulWidget {
  final Match match;
  final Function() notify;

  const SetResultWidget({@required this.match, this.notify});

  @override
  _SetResultWidgetState createState() => _SetResultWidgetState();
}

class _SetResultWidgetState extends State<SetResultWidget> {
  bool _loading;
  final AuthService _auth = AuthService();

  String _matchStyle;
  final List<String> setNames = ['Primeiro Set', 'Segundo Set', 'Terceiro Set'];

  final teamOneSetOneGames = new TextEditingController();
  final teamTwoSetOneGames = new TextEditingController();
  final teamOneSetOneTiebreak = new TextEditingController();
  final teamTwoSetOneTiebreak = new TextEditingController();

  final teamOneSetTwoGames = new TextEditingController();
  final teamTwoSetTwoGames = new TextEditingController();
  final teamOneSetTwoTiebreak = new TextEditingController();
  final teamTwoSetTwoTiebreak = new TextEditingController();

  final teamOneSetThreeGames = new TextEditingController();
  final teamTwoSetThreeGames = new TextEditingController();
  final teamOneSetThreeTiebreak = new TextEditingController();
  final teamTwoSetThreeTiebreak = new TextEditingController();

  Future<int> _updateMatchResult() async {
    setState(() {
      _loading = true;
    });
    final String token = await _auth.getAuthorizationToken();
    final String requestUrl =
        globals.apiMainUrl + '/api/matches/${widget.match.id}/score';

    final body = new Map<String, dynamic>();
    body['sets'] = [];
    var newSet = new Map<String, dynamic>();
    newSet['teamOne'] = int.parse(teamOneSetOneGames.text);
    newSet['teamTwo'] = int.parse(teamTwoSetOneGames.text);
    if (teamOneSetOneTiebreak.text.isNotEmpty)
      newSet['teamOneTiebreak'] = int.parse(teamOneSetOneTiebreak.text);
    if (teamTwoSetOneTiebreak.text.isNotEmpty)
      newSet['teamTwoTiebreak'] = int.parse(teamTwoSetOneTiebreak.text);
    body['sets'].add(newSet);
    if (['2', '3'].contains(_matchStyle)) {
      newSet = new Map<String, dynamic>();
      newSet['teamOne'] = int.parse(teamOneSetTwoGames.text);
      newSet['teamTwo'] = int.parse(teamTwoSetTwoGames.text);
      if (teamOneSetTwoTiebreak.text.isNotEmpty)
        newSet['teamOneTiebreak'] = int.parse(teamOneSetTwoTiebreak.text);
      if (teamTwoSetTwoTiebreak.text.isNotEmpty)
        newSet['teamTwoTiebreak'] = int.parse(teamTwoSetTwoTiebreak.text);
      body['sets'].add(newSet);
    }
    if (_matchStyle == '3') {
      newSet = new Map<String, dynamic>();
      newSet['teamOne'] = int.parse(teamOneSetThreeGames.text);
      newSet['teamTwo'] = int.parse(teamTwoSetThreeGames.text);
      if (teamOneSetThreeTiebreak.text.isNotEmpty)
        newSet['teamOneTiebreak'] = int.parse(teamOneSetThreeTiebreak.text);
      if (teamTwoSetThreeTiebreak.text.isNotEmpty)
        newSet['teamTwoTiebreak'] = int.parse(teamTwoSetThreeTiebreak.text);
      body['sets'].add(newSet);
    }

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    setState(() {
      _loading = false;
      if (response.statusCode == 200) {
        widget.match.sets = body['sets']
            .map((matchSet) => MatchSet.fromJson(matchSet))
            .toList()
            .cast<MatchSet>();
        widget.notify();
      }
    });

    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Column(
        children: <Widget>[
          Text('Resultado da partida',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          DropdownButtonFormField<String>(
            value: _matchStyle,
            decoration: InputDecoration(
              hintText: 'Tipo de partida',
            ),
            items: <List<String>>[
              ['1', 'Um Set'],
              ['2', 'Dois Sets com Tiebreak'],
              ['3', 'Três Sets'],
            ].map((List<String> value) {
              return DropdownMenuItem<String>(
                value: value[0],
                child: Text(value[1]),
              );
            }).toList(),
            onChanged: (String value) {
              setState(() {
                _matchStyle = value;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _matchStyle != null
                      ? MatchSetWidget(
                          name: 'Primeiro Set',
                          teamOneGames: teamOneSetOneGames,
                          teamTwoGames: teamTwoSetOneGames,
                          teamOneTiebreak: teamOneSetOneTiebreak,
                          teamTwoTiebreak: teamTwoSetOneTiebreak,
                        )
                      : Container(),
                  ['2', '3'].contains(_matchStyle)
                      ? MatchSetWidget(
                          name: 'Segundo Set',
                          teamOneGames: teamOneSetTwoGames,
                          teamTwoGames: teamTwoSetTwoGames,
                          teamOneTiebreak: teamOneSetTwoTiebreak,
                          teamTwoTiebreak: teamTwoSetTwoTiebreak,
                        )
                      : Container(),
                  _matchStyle == '3'
                      ? MatchSetWidget(
                          name: 'Terceiro Set',
                          teamOneGames: teamOneSetThreeGames,
                          teamTwoGames: teamTwoSetThreeGames,
                          teamOneTiebreak: teamOneSetThreeTiebreak,
                          teamTwoTiebreak: teamTwoSetThreeTiebreak,
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.center,
              child: RaisedButton(
                child: Text('Publicar'),
                onPressed: () async {
                  var status = await _updateMatchResult();
                  if (status == 200) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MatchSetWidget extends StatefulWidget {
  final String name;
  final TextEditingController teamOneGames;
  final TextEditingController teamTwoGames;
  final TextEditingController teamOneTiebreak;
  final TextEditingController teamTwoTiebreak;

  const MatchSetWidget({
    @required this.name,
    @required this.teamOneGames,
    @required this.teamTwoGames,
    this.teamOneTiebreak,
    this.teamTwoTiebreak,
  });

  @override
  _MatchSetWidgetState createState() => _MatchSetWidgetState();
}

class _MatchSetWidgetState extends State<MatchSetWidget> {
  bool _hasTiebreak = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      child: Column(
        children: <Widget>[
          Text(widget.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: widget.teamOneGames,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    // icon: Icon(Icons.),
                    hintText: ('Games Equipe 1'),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.teamTwoGames,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    // icon: Icon(Icons.),
                    hintText: ('Games Equipe 2'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _hasTiebreak,
                  onChanged: (bool value) {
                    setState(() {
                      _hasTiebreak = value;
                      widget.teamOneTiebreak.text = '';
                      widget.teamTwoTiebreak.text = '';
                    });
                  },
                ),
              ),
              Expanded(
                child: Text('Ocorreu Tiebreak'),
              )
            ],
          ),
          _hasTiebreak
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: widget.teamOneTiebreak,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // icon: Icon(Icons.),
                          hintText: ('Tiebreak Equipe 1'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: widget.teamTwoTiebreak,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // icon: Icon(Icons.),
                          hintText: ('Tiebreak Equipe 2'),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

class MatchSetDisplayWidget extends StatelessWidget {
  final int teamOne;
  final int teamTwo;
  final int teamOneTiebreak;
  final int teamTwoTiebreak;

  const MatchSetDisplayWidget({
    @required this.teamOne,
    @required this.teamTwo,
    this.teamOneTiebreak,
    this.teamTwoTiebreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 30,
          width: 22,
          child: Stack(
            children: <Widget>[
              Text('$teamOne',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              teamOneTiebreak != null
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Text('$teamOneTiebreak'),
                    )
                  : Container()
            ],
          ),
        ),
        SizedBox(width: 6),
        Container(
          height: 30,
          width: 22,
          child: Stack(
            children: <Widget>[
              Text('$teamTwo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              teamTwoTiebreak != null
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Text('$teamTwoTiebreak'),
                    )
                  : Container()
            ],
          ),
        )
      ],
    );
  }
}
