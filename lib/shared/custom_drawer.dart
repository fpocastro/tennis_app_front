import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/shared/take_picture_page.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() {
    return _CustomDrawerState();
  }
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _userId;
  String _name;
  String _email;
  String _pictureUrl;
  String _nameInitials = '';

  void _logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Authorization', null);
    prefs.setString('UserInfo', null);
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userInfoStr = prefs.getString('UserInfo');

    if (userInfoStr != null) {
      var userInfo = json.decode(userInfoStr);
      setState(() {
        _name = userInfo['name'];
        _email = userInfo['email'];
        _pictureUrl = userInfo['pictureUrl'];
        _nameInitials = _name.split(' ').first[0] + _name.split(' ').last[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
                                  builder: (context) =>
                                      TakePicturePage(camera: cameras[1])));
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
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/search_match') {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/search_match');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Eventos'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.person_pin),
            title: Text('Jogadores'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.place),
            title: Text('Locais'),
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
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
