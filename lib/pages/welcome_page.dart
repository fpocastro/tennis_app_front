import 'package:flutter/material.dart';
import 'package:tennis_app_front/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tennisbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Text(
                'Bem vindo ao TennisApp',
                style: TextStyle(fontSize: 30),
                ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 16, right: 8, bottom: 16),
                      height: 50,
                      child: RaisedButton(
                        child: Text('LOGIN'),
                        color: Colors.black,
                        textColor: Colors.white,
                        elevation: 5,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 8, right: 16, bottom: 16),
                      height: 50,
                      child: RaisedButton(
                        child: Text('REGISTRAR'),
                        color: Colors.black,
                        textColor: Colors.white,
                        elevation: 5,
                        onPressed: () {},
                      ),
                    ),
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