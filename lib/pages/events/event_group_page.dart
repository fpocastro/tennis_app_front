import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/event_group.dart';
import 'package:tennis_app_front/pages/events/event_round_page.dart';

class EventGroupPage extends StatefulWidget {
  final EventGroup group;

  const EventGroupPage({Key key, this.group}) : super(key: key);

  @override
  _EventGroupPageState createState() => _EventGroupPageState();
}

class _EventGroupPageState extends State<EventGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 16),
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 16,
            );
          },
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.group.rounds.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EventRoundPage(round: widget.group.rounds[index])),
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
                        widget.group.rounds[index].name,
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
