import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_app_front/pages/account/user_information_page.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/services/database.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';
import 'package:tennis_app_front/shared/image_capture.dart';
import 'package:tennis_app_front/shared/loading.dart';
import 'package:tennis_app_front/shared/take_picture_page.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _auth = AuthService();
  bool _loading = false;
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
    return Scaffold(
      appBar: CustomAppBar('Conta'),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.only(left: 16, right: 16),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 140),
                child: _loading
                    ? Loading(
                        noBackground: true,
                      )
                    : Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              // WidgetsFlutterBinding.ensureInitialized();
                              // final cameras = await availableCameras();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImageCapture()));
                            },
                            child: Container(
                              width: 120,
                              height: 120,
                              margin: EdgeInsets.only(bottom: 8, top: 16),
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
                            _name,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _email,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          Divider(
                            height: 36,
                            thickness: 1,
                          ),
                        ],
                      ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dados pessoais',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              AccountMenuRaisedButton(
                title: 'Informações de usuario',
                redirect: UserInformationPage(),
              ),
              AccountMenuRaisedButton(
                title: 'Configurações da conta',
                redirect: null,
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Suporte',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              AccountMenuRaisedButton(
                title: 'Sobre o TennisApp',
                redirect: null,
              ),
              AccountMenuRaisedButton(
                title: 'Perguntas frequentes',
                redirect: null,
              ),
              AccountMenuRaisedButton(
                title: 'Informações Legais',
                redirect: null,
              ),
              SizedBox(height: 40),
              InkWell(
                child: Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent),
                ),
                onTap: () async {
                  await _auth.signOut();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
              ),
              SizedBox(height: 40),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text('TennisApp v1.0.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: CustomDrawer(),
      ),
    );
  }
}

class AccountMenuRaisedButton extends StatelessWidget {
  final String title;
  final Widget redirect;

  const AccountMenuRaisedButton({
    @required this.title,
    this.redirect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45,
      child: RaisedButton(
        color: Colors.grey[100],
        elevation: 0,
        focusElevation: 0,
        disabledElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        hoverColor: Colors.grey[100],
        disabledColor: Colors.grey[100],
        focusColor: Colors.grey[100],
        highlightColor: Colors.grey[100],
        splashColor: Colors.grey[500],
        padding: EdgeInsets.only(left: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            Icon(
              Icons.chevron_right,
              size: 30,
            ),
          ],
        ),
        onPressed: () {
          if (redirect != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => redirect));
          }
        },
      ),
    );
  }
}
