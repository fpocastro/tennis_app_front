import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_app_front/models/event.dart';
import 'package:tennis_app_front/models/event_group.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/events/event_group_page.dart';
import 'package:tennis_app_front/pages/events/event_manage_groups_page.dart';
import 'package:tennis_app_front/pages/events/event_manage_participants_page.dart';
import 'package:tennis_app_front/pages/places/place_widget.dart';
import 'package:tennis_app_front/pages/players/player_page.dart';
import 'package:tennis_app_front/services/auth.dart';

class EventPage extends StatefulWidget {
  final Event event;

  const EventPage({Key key, this.event}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool _loading = false;
  final AuthService _auth = AuthService();
  User _user;
  String _status = 'general';

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
        title: Text(widget.event.name),
      ),
      floatingActionButton: !_loading &&
              widget.event.creator.uid == _user.uid &&
              ['participants', 'groups'].contains(_status)
          ? FloatingActionButton(
              child: Icon(Icons.create),
              onPressed: () async {
                if (_status == 'participants') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EventManageParticipantsPage(
                              event: widget.event)));
                } else if (_status == 'groups') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EventManageGroupsPage(event: widget.event)));
                }
              },
            )
          : null,
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
                    child: Text('Geral'),
                    color: _status == 'general' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'general') {
                              setState(() {
                                _status = 'general';
                              });
                              // _loadMatches();
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text('Participantes'),
                    color:
                        _status == 'participants' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'participants') {
                              setState(() {
                                _status = 'participants';
                              });
                              // _loadMatches();
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text('Grupos'),
                    color: _status == 'groups' ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (_status != 'groups') {
                              setState(() {
                                _status = 'groups';
                              });
                              // _loadMatches();
                            }
                          },
                  ),
                ],
              ),
            ),
            _status == 'general'
                ? EventGeneralInfoWidget(event: widget.event)
                : _status == 'participants'
                    ? EventParticipantsWidget(
                        participants: widget.event.participants,
                      )
                    : _status == 'groups'
                        ? EventGroupsWidget(groups: widget.event.groups)
                        : Container(),
          ],
        ),
      ),
    );
  }
}

class EventGeneralInfoWidget extends StatelessWidget {
  final Event event;

  const EventGeneralInfoWidget({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              event.name,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Organizado por:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PlayerPage(
                        player: event.creator,
                      )),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundImage: event.creator.pictureUrl != null
                      ? NetworkImage(event.creator.pictureUrl)
                      : null,
                  child: event.creator.pictureUrl == null
                      ? Text(
                          event.creator.name.split(' ').first[0] +
                              event.creator.name.split(' ').last[0],
                          style: TextStyle(fontSize: 22))
                      : null,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.creator.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      event.creator.level != null
                          ? 'Nível ${event.creator.level.toStringAsFixed(1)}'
                          : '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Onde:',
            style: TextStyle(fontSize: 16),
          ),
          PlaceWidget(
            place: event.place,
            favorited: false,
            favoritable: false,
          ),
        ],
      ),
    );
  }
}

class EventParticipantsWidget extends StatelessWidget {
  final String uid;
  final List<User> participants;

  const EventParticipantsWidget({Key key, this.participants, this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.grey[100],
        margin: EdgeInsets.only(left: 8, right: 8),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          separatorBuilder: (context, index) {
            return participants[index].uid != uid ? Divider() : Container();
          },
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: participants.length,
          itemBuilder: (BuildContext context, int index) {
            return participants[index].uid != uid
                ? GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlayerPage(
                                player: participants[index],
                              )),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              participants[index].pictureUrl != null
                                  ? NetworkImage(participants[index].pictureUrl)
                                  : null,
                          child: participants[index].pictureUrl == null
                              ? Text(
                                  participants[index].name.split(' ').first[0] +
                                      participants[index]
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
                              participants[index].name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              participants[index].level != null
                                  ? 'Nível ${participants[index].level.toStringAsFixed(1)}'
                                  : '',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
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
    );
  }
}

class EventGroupsWidget extends StatelessWidget {
  final List<EventGroup> groups;

  const EventGroupsWidget({Key key, this.groups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 16),
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 16,
            );
          },
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: groups.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventGroupPage(group: groups[index])),
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
                    Expanded(
                      child: Text(
                        groups[index].name,
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
    );
  }
}
