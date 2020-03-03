import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:tennis_app_front/pages/search_match/create_new_match_page.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchMatchPage extends StatefulWidget {
  @override
  _SearchMatchPageState createState() {
    return _SearchMatchPageState();
  }
}

class Match {
  final String oponentName;
  final String oponentPictureUlr;
  final DateTime datetime;
  final String placeName;
  // int oponentId;
  // int placeId;

  const Match({
    this.datetime,
    this.oponentName,
    this.oponentPictureUlr,
    this.placeName,
  });
}

class _SearchMatchPageState extends State<SearchMatchPage> {
  List<Match> _matches = [];

  void _loadClosestMatches() async {
    setState(() {
      _matches = [];
      _matches.add(new Match(
          oponentName: 'Novak Djokovic',
          oponentPictureUlr:
              'https://www.gstatic.com/tv/thumb/persons/633923/633923_v9_ba.jpg',
          datetime: DateTime.now(),
          placeName: 'Leopoldina Juvenil'));
      _matches.add(new Match(
          oponentName: 'Roger Federer',
          oponentPictureUlr:
              'https://www.tennisworldusa.org/imgb/89450/water-protection-body-aqua-viva-submits-objection-related-to-roger-federer-s-new-home.jpg',
          datetime: DateTime.now(),
          placeName: 'Dietze Tennis'));
      _matches.add(new Match(
          oponentName: 'Stefanos Tsitsipas',
          oponentPictureUlr:
              'https://i.eurosport.com/2019/01/18/2502955-51957810-2560-1440.jpg',
          datetime: DateTime.now(),
          placeName: 'Dietze Tennis'));
      _matches.add(new Match(
          oponentName: 'Rafael Nadal',
          oponentPictureUlr:
              'https://revistatenis.uol.com.br/media/versions/20190116-nadal-ebden-day-3-009_g_fixed_big.jpg',
          datetime: DateTime.now(),
          placeName: 'Sociedade Libanesa'));
      _matches.add(new Match(
          oponentName: 'Nick Kyrgios',
          oponentPictureUlr:
              'https://www.essentiallysports.com/wp-content/uploads/tennis-nick-kyrgios-wimbledon_4710166.jpg',
          datetime: DateTime.now(),
          placeName: 'Gremio Nautico Uniao'));
      _matches.add(new Match(
          oponentName: 'Danil Medvedev',
          oponentPictureUlr:
              'https://www.tennisworldusa.org/imgb/88960/daniil-medvedev-i-like-rotterdam-it-s-disappointing-to-lose-so-early-.jpg',
          datetime: DateTime.now(),
          placeName: 'Gremio Nautico Uniao'));
      _matches.add(new Match(
          oponentName: 'Dominic Thiem',
          oponentPictureUlr:
              'https://revistatenis.uol.com.br/media/dominic_thiem_programacao_x_zverev.jpg',
          datetime: DateTime.now(),
          placeName: 'Gremio Nautico Uniao'));
      _matches.add(new Match(
          oponentName: 'Gaël Monfils',
          oponentPictureUlr:
              'https://d2me2qg8dfiw8u.cloudfront.net/content/uploads/2019/03/12085724/Gael-Monfils-celebrates-from-PA-752x428.jpg',
          datetime: DateTime.now(),
          placeName: 'Leopoldina Juvenil'));
      _matches.add(new Match(
          oponentName: 'Milos Raonic',
          oponentPictureUlr:
              'https://www.atptour.com/en/news/www.atptour.com/-/media/images/news/2020/01/27/02/16/raonic-australian-open-2020-feature.jpg',
          datetime: DateTime.now(),
          placeName: 'Leopoldina Juvenil'));
      _matches.add(new Match(
          oponentName: 'Denis Shapovalov',
          oponentPictureUlr:
              'https://tenisbrasil.uol.com.br/fotos/2019/shapovalov/0513_roma_olhabola_800_int.jpg',
          datetime: DateTime.now(),
          placeName: 'Sogipa'));
      _matches.add(new Match(
          oponentName: 'Diego Schwartzman',
          oponentPictureUlr:
              'https://upload.wikimedia.org/wikipedia/commons/c/c3/Schwartzman_WM19_%2824%29_%2848521748281%29.jpg',
          datetime: DateTime.now(),
          placeName: 'Sogipa'));
      _matches.add(new Match(
          oponentName: 'Alexander Zverev',
          oponentPictureUlr:
              'https://www.essentiallysports.com/wp-content/uploads/alexander-1600x986.jpg',
          datetime: DateTime.now(),
          placeName: 'Sociedade Libanesa'));
      _matches.add(new Match(
          oponentName: 'Stan Wawrinka',
          oponentPictureUlr:
              'https://www.atptour.com/-/media/tennis/players/head-shot/2019/wawrinka_head_ao19.png',
          datetime: DateTime.now(),
          placeName: 'Sociedade Libanesa'));
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
    super.initState();
    _loadClosestMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Buscar Partida'),
      body: Container(
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
              return Container(
                width: double.infinity,
                height: 70,
                padding: EdgeInsets.only(left: 8, right: 8),
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
                        image: (_matches[index].oponentPictureUlr != null)
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: new NetworkImage(
                                    _matches[index].oponentPictureUlr),
                              )
                            : null,
                      ),
                      child: (_matches[index].oponentPictureUlr == null)
                          ? Center(
                              child: Text(
                                _matches[index]
                                        .oponentName
                                        .split(' ')
                                        .first[0] +
                                    _matches[index]
                                        .oponentName
                                        .split(' ')
                                        .last[0],
                                style: TextStyle(fontSize: 22),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Text(
                            _matches[index].oponentName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            'Onde: ${_matches[index].placeName}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ),
                        Container(
                          child: Text(
                            'Quando: ${new DateFormat('dd/MM/yyyy - hh:mm a').format(_matches[index].datetime)}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
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
