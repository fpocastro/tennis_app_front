import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget bottom;
  CustomAppBar(this.title, {this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: bottom,
      title: Text(title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.message),
          onPressed: () {
            if (ModalRoute.of(context).settings.name != '/messages') {
              Navigator.of(context).pushNamed('/messages');
            }
          },
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
  Size get preferredSize => bottom == null ? new Size.fromHeight(56) : new Size.fromHeight(112);
}
