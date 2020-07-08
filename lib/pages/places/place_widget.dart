import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/places/place_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class PlaceWidget extends StatefulWidget {
  final Place place;
  final bool favorited;
  final bool favoritable;

  const PlaceWidget({Key key, this.place, this.favorited, this.favoritable = true}) : super(key: key);

  @override
  _PlaceWidgetState createState() => _PlaceWidgetState();
}

class _PlaceWidgetState extends State<PlaceWidget> {
  final AuthService _auth = AuthService();
  bool _favorited;

  Future<int> _updateFavorites() async {
    final User user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl + '/api/users/' + user.uid;

    var body = user.toJsonRequest();
    body['favoritePlaces'] = user.favoritePlaces;

    if (body['favoritePlaces'].contains(widget.place.id)) {
      body['favoritePlaces'].removeWhere((item) => item == widget.place.id);
    } else {
      body['favoritePlaces'].add(widget.place.id);
    }

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    if (response.statusCode == 200) {
      await _auth.setCurrentUser(response.body);
    }

    return response.statusCode;
  }

  @override
  void initState() {
    _favorited = widget.favorited;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PlacePage(
                  place: widget.place,
                )),
      ),
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.3),
                blurRadius: 3,
                spreadRadius: 0.5,
                offset: Offset(2, 2)),
          ],
        ),
        width: double.infinity,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: (widget.place.pictureUlr != null && widget.place.pictureUlr != '')
                          ? NetworkImage(widget.place.pictureUlr)
                          : NetworkImage(
                              'https://storage.googleapis.com/tennis-app-bucket/images/places/sem-imagem.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                widget.favoritable ? Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        _favorited ? Icons.star : Icons.star_border,
                        size: 50,
                      ),
                      color: Colors.yellow[600],
                      onPressed: () async {
                        int response = await _updateFavorites();

                        if (response == 200) {
                          setState(() {
                            _favorited = !_favorited;
                          });
                        }
                      },
                    ),
                  ),
                ) : Container(),
              ],
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              color: Colors.grey[100],
              child: Column(
                children: <Widget>[
                  Text(
                    '${widget.place.name}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Divider(),
                  Text(
                    '${widget.place.fullAddress}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
