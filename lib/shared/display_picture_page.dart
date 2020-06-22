import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  // void _submitImage() async {
  //   final String requestUrl = globals.apiMainUrl + 'api/v1/player';
  //   final File _image = File(imagePath);

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String authorization = prefs.getString('Authorization');
  //   final String userInfoStr = prefs.getString('UserInfo');
  //   final int userId = int.parse(json.decode(userInfoStr)['id']);

  //   final body = new Map<String, dynamic>();
  //   body['id'] = userId;
  //   body['picture'] =
  //       'data:image/png;base64,' + base64Encode(_image.readAsBytesSync());

  //   final Map<String, String> headers = {
  //     'Content-Type': 'application/json; charset=utf-8',
  //     'Authorization': authorization
  //   };

  //   final http.Response response = await http.post(
  //     requestUrl,
  //     body: json.encode(body),
  //     headers: headers,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enviar Foto')),
      body: Container(
        color: Colors.orange,
        child: Center(
          child: Image.file(File(imagePath)),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 16,
            ),
            child: FloatingActionButton(
              heroTag: 'back',
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
            ),
            child: FloatingActionButton(
              heroTag: 'submit',
              backgroundColor: Colors.greenAccent,
              child: Icon(Icons.check),
              onPressed: () async {},
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
