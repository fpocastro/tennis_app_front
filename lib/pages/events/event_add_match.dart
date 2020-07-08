import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tennis_app_front/models/event_round.dart';
import 'package:tennis_app_front/models/match.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/players/player_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:tennis_app_front/shared/loading.dart';
import 'package:http/http.dart' as http;

class EventAddMatchPage extends StatefulWidget {
  final EventRound round;
  final List<User> participants;
  final String eventId;
  final String groupId;
  final String placeId;

  const EventAddMatchPage({Key key, this.round, this.participants, this.eventId, this.groupId, this.placeId})
      : super(key: key);

  @override
  _EventAddMatchPageState createState() => _EventAddMatchPageState();
}

class _EventAddMatchPageState extends State<EventAddMatchPage> {
  bool _loading = false;
  final AuthService _auth = AuthService();
  User _user;
  final _formKey = GlobalKey<FormState>();
  String _status = 'no-action';
  String _errorMessage;
  final _dateTextField = TextEditingController();
  final _timeTextField = TextEditingController();
  bool _singles = true;
  var _dateMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  List<String> _selectedPlayers = [];
  List<User> _selectedPlayersObjs = [];

  Future<Match> _createMatch() async {
    setState(() {
      _loading = true;
    });
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/events/' +
        widget.eventId +
        '/group/' +
        widget.groupId +
        '/round/' +
        widget.round.id +
        '/add_match';

    final body = new Map<String, dynamic>();
    body['numberOfPlayers'] = _singles ? 2 : 4;
    var dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    var matchDate =
        dateFormat.parse(_dateTextField.text + " " + _timeTextField.text);
    body['matchDate'] = matchDate.toString();
    body['players'] = _selectedPlayers;
    body['place'] = widget.placeId;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.post(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    setState(() {
      _loading = false;
    });

    return response.statusCode == 200
        ? new Match.fromJson(json.decode(response.body))
        : null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Partida')),
      body: Container(
        height: double.infinity,
        color: Colors.grey[100],
        padding: EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12)),
                          color:
                              _singles ? Colors.greenAccent : Colors.grey[200],
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        child: Text(
                          'Dois Jogadores',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _singles = true;
                          _selectedPlayers = [];
                          _selectedPlayersObjs = [];
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          color:
                              !_singles ? Colors.greenAccent : Colors.grey[200],
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        child: Text(
                          'Quatro Jogadores',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _singles = false;
                          _selectedPlayers = [];
                          _selectedPlayersObjs = [];
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _dateTextField,
                    validator: (value) {
                      DateTime date = DateTime.parse(value);
                      print(date);
                      if (date.difference(DateTime.now()).inDays > 0) {
                        return null;
                      }
                      return 'Data Inválida';
                    },
                    decoration: InputDecoration(
                      hintText: ('Informe a data da partida'),
                      labelText: ('Data da partida'),
                    ),
                    inputFormatters: <TextInputFormatter>[_dateMask],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showTimePicker(
                              context: context, initialTime: TimeOfDay.now())
                          .then((time) {
                        _timeTextField.text = time.format(context);
                      });
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _timeTextField,
                        readOnly: true,
                        // validator: _validatePassword,
                        decoration: InputDecoration(
                          hintText: ('Qual horário você quer jogar?'),
                          labelText: ('Horário'),
                        ),
                      ),
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
                Text(
                  'Jogadores',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                child: _loading
                    ? Loading(
                        noBackground: true,
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: widget.participants.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 8,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: EdgeInsets.all(4),
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
                                  child: _selectedPlayers.contains(
                                          widget.participants[index].uid)
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              _selectedPlayers.removeWhere(
                                                  (playerId) =>
                                                      playerId ==
                                                      widget.participants[index]
                                                          .uid);
                                              _selectedPlayersObjs.removeWhere(
                                                  (player) =>
                                                      player.uid ==
                                                      widget.participants[index]
                                                          .uid);
                                            });
                                          },
                                        )
                                      : (_singles &&
                                                  _selectedPlayers.length >=
                                                      2) ||
                                              (!_singles &&
                                                  _selectedPlayers.length >= 4)
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.block,
                                                color: Colors.yellowAccent,
                                              ),
                                              onPressed: () async {},
                                            )
                                          : IconButton(
                                              icon: Icon(
                                                Icons.add_circle,
                                                color: Colors.greenAccent,
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  _selectedPlayers.add(widget
                                                      .participants[index].uid);
                                                  _selectedPlayersObjs.add(
                                                      widget
                                                          .participants[index]);
                                                });
                                              },
                                            ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PlayerPage(
                                              player:
                                                  widget.participants[index],
                                            )),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: widget
                                                    .participants[index]
                                                    .pictureUrl !=
                                                null
                                            ? NetworkImage(widget
                                                .participants[index].pictureUrl)
                                            : null,
                                        child: widget.participants[index]
                                                    .pictureUrl ==
                                                null
                                            ? Text(
                                                widget.participants[index].name
                                                        .split(' ')
                                                        .first[0] +
                                                    widget.participants[index]
                                                        .name
                                                        .split(' ')
                                                        .last[0],
                                                style: TextStyle(fontSize: 22))
                                            : null,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.participants[index].name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            widget.participants[index].level !=
                                                    null
                                                ? 'Nível ${widget.participants[index].level.toStringAsFixed(1)}'
                                                : '',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Equipe 1', style: TextStyle(fontSize: 16)),
                    Text('Equipe 2', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Divider(),
                _singles
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _selectedPlayersObjs.length > 0
                              ? Text(_selectedPlayersObjs[0].name)
                              : Container(),
                          _selectedPlayersObjs.length > 1
                              ? Text(_selectedPlayersObjs[1].name)
                              : Container(),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _selectedPlayersObjs.length > 0
                                  ? Text(_selectedPlayersObjs[0].name)
                                  : Container(),
                              _selectedPlayersObjs.length > 1
                                  ? Text(_selectedPlayersObjs[1].name)
                                  : Container(),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _selectedPlayersObjs.length > 2
                                  ? Text(_selectedPlayersObjs[2].name)
                                  : Container(),
                              _selectedPlayersObjs.length > 3
                                  ? Text(_selectedPlayersObjs[3].name)
                                  : Container(),
                            ],
                          )
                        ],
                      ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 8, bottom: 8),
              width: double.infinity,
              child: RaisedButton(
                onPressed: () async {
                  Match match = await _createMatch();
                  if (match != null) {
                    Fluttertoast.showToast(
                        msg: 'Partida Criada',
                        backgroundColor: Colors.greenAccent,
                        toastLength: Toast.LENGTH_LONG);
                    widget.round.matches.add(match);
                  }
                },
                child: Text('Criar Partida'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
