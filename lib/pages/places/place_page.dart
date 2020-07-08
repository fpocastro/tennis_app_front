import 'package:flutter/material.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/shared/map_page.dart';

class PlacePage extends StatelessWidget {
  final Place place;

  const PlacePage({Key key, this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: Container(
        color: Colors.grey[300],
        width: double.infinity,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: (place.pictureUlr != null && place.pictureUlr != '')
                      ? NetworkImage(place.pictureUlr)
                      : NetworkImage(
                          'https://storage.googleapis.com/tennis-app-bucket/images/places/sem-imagem.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.5),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: Offset(4, 5)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                width: double.infinity,
                padding:
                    EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Text(
                      '${place.name}',
                      style: TextStyle(fontSize: 18),
                    )),
                    Divider(),
                    (place.phone != null)
                        ? Row(children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: Icon(Icons.phone),
                            ),
                            Text(
                              '${place.phone}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ])
                        : Container(height: 0, width: 0),
                    (place.website != null)
                        ? Row(children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: Icon(Icons.web),
                            ),
                            Text(
                              '${place.website}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ])
                        : Container(height: 0, width: 0),
                    Divider(),
                    Text(
                      '${place.fullAddress}',
                      style: TextStyle(fontSize: 14),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapPage(place: place))),
                      child: Text(
                        'Ver no mapa',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
