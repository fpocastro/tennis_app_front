import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final bool noBackground;

  const Loading({this.noBackground = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: noBackground ? null : BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tennisbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SpinKitChasingDots(
            color: Colors.black,
            size: 50,
          ),
        ));
  }
}
