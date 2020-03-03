import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/pages/places/place_page.dart';

class PlaceWidget extends StatelessWidget {
  final Place place;

  const PlaceWidget({Key key, this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlacePage(place: place,)),
      ),
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.3),
                blurRadius: 3,
                spreadRadius: 0.5,
                offset: Offset(2, 2)),
          ],
        ),
        width: double.infinity,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: (place.pictureUlr != null)
                      ? NetworkImage(place.pictureUlr)
                      : NetworkImage(
                          'https://images.unsplash.com/photo-1557766131-dca3a8acae87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3582&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              color: Colors.grey[100],
              child: Column(
                children: <Widget>[
                  Text(
                    '${place.name}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Divider(),
                  Text(
                    '${place.fullAddress}',
                    style: TextStyle(fontSize: 12),
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
