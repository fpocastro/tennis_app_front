import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:tennis_app_front/models/match.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/search_match/create_new_match_page.dart';
import 'package:tennis_app_front/pages/search_match/match_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';

class SearchMatchPage extends StatefulWidget {
  @override
  _SearchMatchPageState createState() {
    return _SearchMatchPageState();
  }
}

class _SearchMatchPageState extends State<SearchMatchPage> {
  bool _loading = false;
  final AuthService _auth = AuthService();
  User _user;
  List<Match> _matches = [];

  void _loadClosestMatches() async {
    setState(() {
      _loading = true;
    });

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/matches?status=open&latLng=${position.longitude},${position.latitude}&maxDistance=' +
        (_user.playersSearchDistance * 1000).toString() +
        '&matchDate=${DateTime.now().toString()}';

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.get(
      requestUrl,
      headers: headers,
    );

    final List parsedList = json.decode(response.body);

    var matches = parsedList.map((s) => Match.fromJson(s)).toList();
    matches.removeWhere((match) =>
        match.creator.uid == _user.uid ||
        (match.teamOne.where((player) => player.uid == _user.uid).isNotEmpty ||
            match.teamTwo
                .where((player) => player.uid == _user.uid)
                .isNotEmpty));

    setState(() {
      _matches = matches;
      _loading = false;
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _loadClosestMatches();

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    _loadClosestMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Buscar Partida'),
      body: _loading
          ? Loading(noBackground: true)
          : _matches.where((match) => match.creator.uid != _user.uid).length ==
                  0
              ? Container(
                  color: Colors.grey[100],
                  child: Center(
                      child: Text(
                    'Nenhuma partida encontrada',
                    style: TextStyle(fontSize: 16),
                  )))
              : Container(
                  color: Colors.grey[100],
                  width: double.infinity,
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      separatorBuilder: (context, index) => Divider(),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      (_matches[index].numberOfPlayers == 2
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
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                                _matches[index].creator.name),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Divider(),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: _matches[index]
                                                        .teamTwo
                                                        .length >
                                                    0
                                                ? Text(_matches[index]
                                                    .teamTwo[0]
                                                    .name)
                                                : Text('Aguardando Jogador',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blueAccent)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    _matches[index].teamTwo.length > 0
                                        ? UserImageWidget(
                                            user: _matches[index].teamTwo[0],
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
                                  height: _matches[index].numberOfPlayers != 2
                                      ? 8
                                      : 0,
                                ),
                                _matches[index].numberOfPlayers != 2
                                    ? Row(
                                        children: <Widget>[
                                          _matches[index].teamOne.length > 1
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
                                                  alignment: Alignment.topLeft,
                                                  child: _matches[index]
                                                              .teamOne
                                                              .length >
                                                          1
                                                      ? Text(_matches[index]
                                                          .teamOne[1]
                                                          .name)
                                                      : Text(
                                                          'Aguardando Jogador',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent)),
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
                                                          1
                                                      ? Text(_matches[index]
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
                                          _matches[index].teamTwo.length > 1
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
                                  child: Text(
                                    'Locais',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: 50, maxHeight: 100),
                                  child: ListView.separated(
                                      shrinkWrap: true,
                                      padding:
                                          EdgeInsets.only(top: 4, bottom: 4),
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            height: 4,
                                          ),
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount:
                                          _matches[index].possiblePlaces.length,
                                      itemBuilder: (BuildContext context,
                                          int placeIndex) {
                                        return Text(
                                          _matches[index]
                                              .possiblePlaces[placeIndex]
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateNewMatchPage()));
        },
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
