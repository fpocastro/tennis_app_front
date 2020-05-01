import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tennis_app_front/models/message.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/shared/loading.dart';

class ChatPage extends StatefulWidget {
  final String userId;

  const ChatPage({Key key, this.userId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _loading = true;
  final AuthService _auth = AuthService();
  Socket socket;
  User _chatUser;
  User _user;
  String _token;
  final _messageTextField = TextEditingController();
  List<dynamic> _messages = [];
  ScrollController _scrollController = new ScrollController();

  void setChat() async {
    setState(() => _loading = true);
    String requestUrl = globals.apiMainUrl + '/api/users/';

    _user = await _auth.getCurrentUser();
    _token = await _auth.getAuthorizationToken();

    final Map<String, String> headers = {
      'Authorization': _token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.get(
      requestUrl + widget.userId,
      headers: headers,
    );

    socket = io(globals.apiMainUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'_id': _user.uid}
    });
    socket.connect();

    socket.on('receive_message', (jsonData) {
      Map<String, dynamic> data = new Map<String, dynamic>.from(jsonData);
      if (mounted) {
        this.setState(() => _messages.insert(0, new Message.fromJson(data)));
      }
    });

    setState(() {
      _chatUser = User.fromJson(json.decode(response.body));
    });

    requestUrl = globals.apiMainUrl + '/api/chats/' + widget.userId;

    response = await http.get(
      requestUrl,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var messages = json.decode(response.body)['messages'];
      setState(() {
        _messages =
            messages.map((message) => new Message.fromJson(message)).toList();
        _scrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    setChat();
    super.initState();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_chatUser == null ? '' : _chatUser.name)),
      body: _chatUser == null
          ? Loading(
              noBackground: true,
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final bool isMe = _messages[index].senderId == _user.uid;
                      return Container(
                        margin: isMe
                            ? EdgeInsets.only(top: 4.0, bottom: 4, left: 80)
                            : EdgeInsets.only(top: 4.0, bottom: 4, right: 80),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: isMe
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))
                              : BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              new DateFormat('dd/MM/yyyy - hh:mm a')
                                  .format(_messages[index].time),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(_messages[index].text),
                          ],
                        ),
                      );
                      // return Text(_messages[index]);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              color: Colors.orangeAccent),
                          child: TextField(
                            controller: _messageTextField,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration.collapsed(
                                hintText: 'Digite uma mensagem...'),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        iconSize: 25,
                        color: Colors.orange,
                        onPressed: () {
                          if (_messageTextField.text != '') {
                            Map<String, dynamic> messageObj = {
                              'message': {
                                'text': _messageTextField.text,
                                'senderId': _user.uid,
                                'receiverId': _chatUser.uid,
                              },
                              'token': _token
                            };
                            socket.emit('send_message', messageObj);
                            Message newMessage =
                                new Message.fromJson(messageObj['message']);
                            newMessage.time = DateTime.now();
                            this.setState(() => _messages.add(newMessage));
                            _messageTextField.text = '';
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
      // : Container(
      //     child: Flex(
      //       direction: Axis.vertical,
      //       children: <Widget>[
      //         RaisedButton(
      //           onPressed: () {
      //             socket.emit(
      //                 'send_message', {'message': 'teste', 'senderId': _user.uid, 'receiverId': _chatUser.uid});
      //           },
      //           child: Text('Send Message'),
      //         ),
      //         RaisedButton(
      //           onPressed: () {
      //             socket.disconnect();
      //           },
      //           child: Text('Disconnect'),
      //         ),
      //         Container(
      //           height: 300,
      //           child: ListView.separated(
      //               padding: EdgeInsets.only(top: 16, bottom: 16),
      //               separatorBuilder: (context, index) => Divider(),
      //               physics: const AlwaysScrollableScrollPhysics(),
      //               itemCount: _messages.length,
      //               itemBuilder: (BuildContext context, int index) {
      //                 return Text(_messages[index]);
      //               }),
      //         ),
      //       ],
      //     ),
      //   ),
    );
  }
}
