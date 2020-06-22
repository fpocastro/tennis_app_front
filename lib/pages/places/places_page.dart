import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/pages/places/place_widget.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/services/database.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:tennis_app_front/shared/loading.dart';

class PlacesPage extends StatefulWidget {
  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  List<dynamic> _places = [];
  final AuthService _auth = AuthService();
  User _user;
  bool _loading = false;
  bool displayFavorites = false;

  void _getClosestPlaces() async {
    setState(() {
      _loading = true;
    });
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl +
        '/api/places?latLng=${position.longitude},${position.latitude}&maxDistance=' +
        (_user.placesSearchDistance * 1000).toString();

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.get(
      requestUrl +
          position.longitude.toString() +
          ',' +
          position.latitude.toString(),
      headers: headers,
    );

    final List parsedList = json.decode(response.body);

    setState(() {
      _places = parsedList.map((s) => Place.fromJson(s)).toList();
      _loading = false;
    });
  }

  void _getFavoritPlaces() async {
    setState(() {
      _loading = true;
    });
    final String requestUrl = globals.apiMainUrl + '/api/users/places';

    _user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

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
      _places = parsedList.map((s) => Place.fromJson(s)).toList();
      _loading = false;
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    if (displayFavorites) {
      _getFavoritPlaces();
    } else {
      _getClosestPlaces();
    }

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    _getClosestPlaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Locais'),
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
                    child: Text('Todos'),
                    color: displayFavorites ? null : Colors.orange[300],
                    onPressed: _loading
                        ? null
                        : () {
                            if (displayFavorites) {
                              _getClosestPlaces();
                              setState(() {
                                displayFavorites = !displayFavorites;
                              });
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text('Favoritos'),
                    color: displayFavorites ? Colors.orange[300] : null,
                    onPressed: _loading
                        ? null
                        : () {
                            if (!displayFavorites) {
                              _getFavoritPlaces();
                              setState(() {
                                displayFavorites = !displayFavorites;
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
            _loading
                ? Expanded(child: Center(child: Loading(noBackground: true)))
                : Expanded(
                    child: Container(
                      width: double.infinity,
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _places.length,
                          itemBuilder: (BuildContext context, int index) {
                            return PlaceWidget(
                                place: _places[index],
                                favorited: _user.favoritePlaces
                                    .contains(_places[index].id));
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      drawer: Drawer(
        child: CustomDrawer(),
      ),
    );
  }
}
