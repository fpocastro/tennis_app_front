import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  CustomAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.message),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            if (ModalRoute.of(context).settings.name != '/account') {
              Navigator.of(context).pushNamed('/account');
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(56);
}
