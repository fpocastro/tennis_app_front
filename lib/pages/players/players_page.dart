import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/players/player_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';

class PlayersPage extends StatefulWidget {
  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  List<User> _contacts = [];
  bool _loading = false;
  final AuthService _auth = AuthService();
  User _user;

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
        (_user.playersSearchDistance * 1000).toString();

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
      _contacts = parsedList.map((s) => User.fromJson(s)).toList();
      _loading = false;
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _loadPlayers();

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    _loadPlayers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Jogadores'),
      body: _loading
          ? Loading(noBackground: true)
          : Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              color: Colors.grey[100],
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  separatorBuilder: (context, index) {
                    return _contacts[index].uid != _user.uid
                        ? Divider()
                        : Container();
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _contacts[index].uid != _user.uid
                        ? GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlayerPage(
                                        player: _contacts[index],
                                      )),
                            ),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage:
                                      _contacts[index].pictureUrl != null
                                          ? NetworkImage(
                                              _contacts[index].pictureUrl)
                                          : null,
                                  child: _contacts[index].pictureUrl == null
                                      ? Text(
                                          _contacts[index]
                                                  .name
                                                  .split(' ')
                                                  .first[0] +
                                              _contacts[index]
                                                  .name
                                                  .split(' ')
                                                  .last[0],
                                          style: TextStyle(fontSize: 22))
                                      : null,
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _contacts[index].name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _contacts[index].level != null
                                          ? 'Nível ${_contacts[index].level.toStringAsFixed(1)}'
                                          : '',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Locais favoritos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container();
                  },
                ),
              ),
            ),
      drawer: CustomDrawer(),
    );
  }
}
