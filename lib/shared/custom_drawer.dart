import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/services/database.dart';
import 'package:tennis_app_front/shared/image_capture.dart';
import 'package:tennis_app_front/shared/take_picture_page.dart';

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

  void _logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Authorization', null);
    prefs.setString('UserInfo', null);
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  // void _loadUserInfo() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String userInfoStr = prefs.getString('UserInfo');

  //   if (userInfoStr != null) {
  //     var userInfo = json.decode(userInfoStr);
  //     setState(() {
  //       _name = userInfo['name'];
  //       _email = userInfo['email'];
  //       _pictureUrl = userInfo['pictureUrl'];
  //       _nameInitials = _name.split(' ').first[0] + _name.split(' ').last[0];
  //     });
  //   }
  // }

  void _getUserInfo() async {
    setState(() {
      _loading = true;
    });
    final FirebaseUser user = await AuthService().getCurrentUser();
    final dynamic userInfo = await DatabaseService(uid: user.uid).getUserData();
    String filePath = 'images/profiles/${user.uid}';
    final ref = FirebaseStorage.instance.ref().child(filePath);
    await ref.getDownloadURL().then((url) {
      setState(() {
        _pictureUrl = url;
      });
    }, onError: (error) {});
    setState(() {
      _name = userInfo['name'];
      _email = user.email;
      _nameInitials = userInfo['name'].toString().split(' ').first[0] +
          userInfo['name'].toString().split(' ').last[0];
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
            onTap: () async {
              await _auth.signOut();
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
    );
  }
}
