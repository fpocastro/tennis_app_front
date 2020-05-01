import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/chat/chat_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/loading.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class PlayerPage extends StatefulWidget {
  final User player;

  const PlayerPage({Key key, this.player}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player.name),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 140),
                child: _loading
                    ? Loading(
                        noBackground: true,
                      )
                    : Column(
                        children: <Widget>[
                          Container(
                            width: 120,
                            height: 120,
                            margin: EdgeInsets.only(bottom: 8, top: 16),
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
                              image: (widget.player.pictureUrl != null)
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: new NetworkImage(
                                          widget.player.pictureUrl),
                                    )
                                  : null,
                            ),
                            child: (widget.player.pictureUrl == null)
                                ? Center(
                                    child: Text(
                                      widget.player.name.split(' ').first[0] +
                                          widget.player.name.split(' ').last[0],
                                      style: TextStyle(fontSize: 22),
                                    ),
                                  )
                                : null,
                          ),
                          Text(
                            widget.player.name,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.player.level != null
                                ? 'Nível ${widget.player.level.toStringAsFixed(1)}'
                                : '',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          Divider(
                            height: 36,
                            thickness: 1,
                          ),
                          widget.player.dateOfBirth != null
                              ? PlayerInfoItem(
                                  title: 'Idade',
                                  value: (DateTime.now()
                                              .difference(
                                                  widget.player.dateOfBirth)
                                              .inDays /
                                          365)
                                      .floor()
                                      .toString(),
                                )
                              : Container(),
                          widget.player.height != null
                              ? PlayerInfoItem(
                                  title: 'Altura',
                                  value: widget.player.height.toString(),
                                )
                              : Container(),
                          widget.player.weight != null
                              ? PlayerInfoItem(
                                  title: 'Peso',
                                  value: widget.player.weight.toString(),
                                )
                              : Container(),
                          widget.player.laterality != null
                              ? PlayerInfoItem(
                                  title: 'Lateralidade',
                                  value: widget.player.laterality,
                                )
                              : Container(),
                          widget.player.backhand != null
                              ? PlayerInfoItem(
                                  title: 'Backhand',
                                  value: widget.player.backhand,
                                )
                              : Container(),
                          widget.player.court != null
                              ? PlayerInfoItem(
                                  title: 'Quadra Favorita',
                                  value: widget.player.court,
                                )
                              : Container(),
                          RaisedButton(
                            child: Text('Enviar Mensagem'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                          userId: widget.player.uid,
                                        )),
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerInfoItem extends StatelessWidget {
  final String title;
  final String value;

  const PlayerInfoItem({
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
