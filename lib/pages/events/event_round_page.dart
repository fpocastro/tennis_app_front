import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_app_front/models/event_group.dart';
import 'package:tennis_app_front/models/event_round.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/loading.dart';

class EventRoundPage extends StatefulWidget {
  final EventRound round;

  const EventRoundPage({Key key, this.round}) : super(key: key);

  @override
  _EventRoundPageState createState() => _EventRoundPageState();
}

class _EventRoundPageState extends State<EventRoundPage> {
  bool _loading = true;
  final AuthService _auth = AuthService();
  User _user;

  void _loadUser() async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.round.name),
      ),
      body: _loading
          ? Center(child: Loading(noBackground: true))
          : Container(
              color: Colors.grey[100],
              padding: EdgeInsets.all(8),
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 16),
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 8,
                  );
                },
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: widget.round.matches.length,
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
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              (widget.round.matches[index].numberOfPlayers == 2
                                  ? 'Simples'
                                  : 'Duplas'),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                                ' - ${new DateFormat('dd/MM/yyyy - hh:mm a').format(widget.round.matches[index].matchDate)}')
                          ],
                        ),
                        Divider(thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Equipe 1',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Equipe 2',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            UserImageWidget(
                              user: widget.round.matches[index].teamOne[0],
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(widget
                                        .round.matches[index].teamOne[0].name),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Divider(),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: widget.round.matches[index].teamTwo
                                                .length >
                                            0
                                        ? Text(widget.round.matches[index]
                                            .teamTwo[0].name)
                                        : Text('Aguardando Jogador',
                                            style: TextStyle(
                                                color: Colors.blueAccent)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            widget.round.matches[index].teamTwo.length > 0
                                ? UserImageWidget(
                                    user:
                                        widget.round.matches[index].teamTwo[0],
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
                              widget.round.matches[index].numberOfPlayers != 2
                                  ? 8
                                  : 0,
                        ),
                        widget.round.matches[index].numberOfPlayers != 2
                            ? Row(
                                children: <Widget>[
                                  widget.round.matches[index].teamOne.length > 1
                                      ? UserImageWidget(
                                          user: widget
                                              .round.matches[index].teamOne[1],
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
                                          child: widget.round.matches[index]
                                                      .teamOne.length >
                                                  1
                                              ? Text(widget.round.matches[index]
                                                  .teamOne[1].name)
                                              : Text('Aguardando Jogador',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.blueAccent)),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Divider(),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: widget.round.matches[index]
                                                      .teamTwo.length >
                                                  1
                                              ? Text(widget.round.matches[index]
                                                  .teamTwo[1].name)
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
                                  widget.round.matches[index].teamTwo.length > 1
                                      ? UserImageWidget(
                                          user: widget
                                              .round.matches[index].teamTwo[1],
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
                        widget.round.matches[index].sets.length > 0
                            ? Divider(thickness: 1)
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            widget.round.matches[index].sets.length > 0
                                ? MatchSetDisplayWidget(
                                    teamOne: widget
                                        .round.matches[index].sets[0].teamOne,
                                    teamOneTiebreak: widget.round.matches[index]
                                        .sets[0].teamOneTiebreak,
                                    teamTwo: widget
                                        .round.matches[index].sets[0].teamTwo,
                                    teamTwoTiebreak: widget.round.matches[index]
                                        .sets[0].teamTwoTiebreak,
                                  )
                                : Container(),
                            SizedBox(width: 16),
                            widget.round.matches[index].sets.length > 1
                                ? MatchSetDisplayWidget(
                                    teamOne: widget
                                        .round.matches[index].sets[1].teamOne,
                                    teamOneTiebreak: widget.round.matches[index]
                                        .sets[1].teamOneTiebreak,
                                    teamTwo: widget
                                        .round.matches[index].sets[1].teamTwo,
                                    teamTwoTiebreak: widget.round.matches[index]
                                        .sets[1].teamTwoTiebreak,
                                  )
                                : Container(),
                            SizedBox(width: 16),
                            widget.round.matches[index].sets.length > 2
                                ? MatchSetDisplayWidget(
                                    teamOne: widget
                                        .round.matches[index].sets[2].teamOne,
                                    teamOneTiebreak: widget.round.matches[index]
                                        .sets[2].teamOneTiebreak,
                                    teamTwo: widget
                                        .round.matches[index].sets[2].teamTwo,
                                    teamTwoTiebreak: widget.round.matches[index]
                                        .sets[2].teamTwoTiebreak,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
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
        SizedBox(
          width: 6,
        ),
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
