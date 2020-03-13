import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tennis_app_front/models/place.dart';
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
  bool _loading = false;

  // void _getClosestPlaces() async {
  //   final String requestUrl = globals.apiMainUrl + 'api/v1/places';

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String authorization = prefs.getString('Authorization');

  //   final Map<String, String> headers = {
  //     'Authorization': authorization,
  //     'Content-Type': 'application/json'
  //   };

  //   http.Response response = await http.get(
  //     requestUrl,
  //     headers: headers,
  //   );

  //   final List parsedList = json.decode(response.body)['content'];

  //   setState(() {
  //     _places = parsedList.map((s) => Place.fromJson(s)).toList();
  //   });
  // }

  void _getPlaces() async {
    setState(() {
      _loading = true;
    });
    final FirebaseUser user = await AuthService().getCurrentUser();
    final dynamic places = await DatabaseService(uid: user.uid).getPlaces();
    final parsedList = places.documents.map((s) => Place.fromSnapshot(s)).toList();
    setState(() {
      _places = parsedList;
      _loading = false;
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _getPlaces();

    completer.complete();

    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    _getPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Locais'),
      body: _loading ? Loading(noBackground: true) : Container(
        color: Colors.grey[300],
        width: double.infinity,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _places.length,
            itemBuilder: (BuildContext context, int index) {
              return PlaceWidget(place: _places[index]);
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: CustomDrawer(),
      ),
    );
  }
}
