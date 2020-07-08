import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/event.dart';
import 'package:tennis_app_front/models/event_group.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/events/event_group_page.dart';
import 'package:tennis_app_front/pages/events/event_manage_rounds.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';

class EventManageGroupsPage extends StatefulWidget {
  final Event event;

  const EventManageGroupsPage({Key key, this.event}) : super(key: key);

  @override
  _EventManageGroupsPageState createState() => _EventManageGroupsPageState();
}

class _EventManageGroupsPageState extends State<EventManageGroupsPage> {
  bool _loading = false;
  final AuthService _auth = AuthService();
  User _user;
  final _nameTextField = TextEditingController();

  Future<int> _addGroup() async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl =
        globals.apiMainUrl + '/api/events/' + widget.event.id + '/add_group/';

    final body = new Map<String, dynamic>();
    body['name'] = _nameTextField.text;

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
      widget.event.groups = Event.fromJson(json.decode(response.body)).groups;
      _loading = false;
    });

    return response.statusCode;
  }

  Future<int> _removeGroup(String groupId) async {
    setState(() {
      _loading = true;
    });
    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    print(groupId);

    final String requestUrl = globals.apiMainUrl +
        '/api/events/' +
        widget.event.id +
        '/remove_group/' +
        groupId;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.delete(
      requestUrl,
      headers: headers,
    );

    setState(() {
      _loading = false;
    });

    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Grupos'),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _nameTextField,
                    validator: (value) {
                      return null;
                    },
                    decoration: InputDecoration(
                      // icon: Icon(Icons.),
                      hintText: ('Informe o nome do grupo'),
                      labelText: ('Novo grupo'),
                    ),
                  ),
                  SizedBox(height: 16),
                  RaisedButton(
                    color: Colors.greenAccent,
                    child: Text('Adicionar'),
                    onPressed: () async {
                      int response = await _addGroup();
                      if (response == 200) {
                        var eventGroup = new EventGroup.fromJson(
                            {'name': _nameTextField.text, 'rounds': []});
                        setState(() {
                          // widget.event.groups.add(eventGroup);
                          _nameTextField.text = '';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? Center(child: Loading(noBackground: true))
                  : Container(
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: 16),
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 16,
                          );
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: widget.event.groups.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EventManageRounds(event: widget.event, groupId: widget.event.groups[index].id,)),
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
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      int response = await _removeGroup(
                                          widget.event.groups[index].id);
                                      if (response == 200) {
                                        setState(() {
                                          widget.event.groups.removeWhere(
                                              (group) =>
                                                  group.id ==
                                                  widget
                                                      .event.groups[index].id);
                                        });
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.event.groups[index].name,
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
            ),
          ],
        ),
      ),
    );
  }
}
