import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';

class IntroSecondPage extends StatefulWidget {
  @override
  _IntroSecondPageState createState() => _IntroSecondPageState();
}

class _IntroSecondPageState extends State<IntroSecondPage> {
  LatLng _lastLocation;

  void getLastLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _lastLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void initState() {
    getLastLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 16, right: 16, top: 64),
        color: Colors.orange[100],
        child: Column(
          children: <Widget>[
            Text(
              'Informe seu endereço!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Não vamos compartilhar com ninguém!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Caso não informado, utilizaremos apenas a posição do seu dispositivo na busca de partidas.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8,
            ),
            _lastLocation != null ? 
            SearchMapPlaceWidget(
              apiKey: 'AIzaSyDT9B19UcOc3jhYOZ4FTxNx3ZpFFwtmVA4',
              language: 'en',
              location: _lastLocation,
              radius: 30000,
              onSelected: (Place place) async {
                final geolocation = await place.fullJSON;
                print(geolocation);
              },
            ) : Container(), 
            SizedBox(
              height: 8,
            ),
            RaisedButton(
              child: Text('home'),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            )
            // TODO: ADICIONAR PÁGINA DE ENDEREÇO DO USUÁRIO!
          ],
        ),
      ),
    );
  }
}
