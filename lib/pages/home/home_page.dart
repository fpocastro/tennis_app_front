import 'package:flutter/material.dart';
import 'package:tennis_app_front/shared/custom_appbar.dart';
import 'package:tennis_app_front/shared/custom_drawer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Home'),
      body: Center(),
      drawer: Drawer(
        child: CustomDrawer(),
      ),
    );
  }
}
