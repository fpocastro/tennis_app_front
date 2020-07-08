import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/image_capture.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() {
    return _CustomDrawerState();
  }
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService _auth = AuthService();
  bool _loading = false;
  int _userId;
  String _name = '';
  String _email = '';
  String _pictureUrl;
  String _nameInitials = '';

  void _getUserInfo() async {
    setState(() {
      _loading = true;
    });
    final User user = await AuthService().getCurrentUser();
    setState(() {
      _name = user.name;
      _email = user.email;
      _nameInitials =
          user.name.split(' ').first[0] + user.name.split(' ').last[0];
      _pictureUrl = user.pictureUrl;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          WidgetsFlutterBinding.ensureInitialized();
                          final cameras = await availableCameras();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImageCapture()));
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          margin: EdgeInsets.only(bottom: 8),
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
                            image: (_pictureUrl != null)
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: new NetworkImage(_pictureUrl),
                                  )
                                : null,
                          ),
                          child: (_pictureUrl == null)
                              ? Center(
                                  child: Text(
                                    _nameInitials,
                                    style: TextStyle(fontSize: 22),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Text(
                        '$_name',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('$_email', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            selected: ModalRoute.of(context).settings.name == '/home' || ModalRoute.of(context).settings.name == '/',
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/home' &&
                  ModalRoute.of(context).settings.name != '/') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/home');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Buscar Partida'),
            selected: ModalRoute.of(context).settings.name == '/search_match',
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/search_match') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/search_match');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Minhas Partidas'),
            selected: ModalRoute.of(context).settings.name == '/matches',
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/matches') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/matches');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Eventos'),
            selected: ModalRoute.of(context).settings.name == '/events',
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/events') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/events');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.person_pin),
            title: Text('Jogadores'),
            selected: ModalRoute.of(context).settings.name == '/players',
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/players') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/players');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.place),
            title: Text('Locais'),
            selected: ModalRoute.of(context).settings.name == '/places',
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/places') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/places');
              }
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Conta'),
            selected: ModalRoute.of(context).settings.name == '/account',
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/account') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/account');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.vpn_key),
            title: Text('Logout'),
            onTap: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
