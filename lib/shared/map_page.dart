import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tennis_app_front/models/place.dart';

class MapPage extends StatefulWidget {
  final Place place;

  const MapPage({Key key, this.place}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  String _mapStyle;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final MarkerId markerId = MarkerId(widget.place.id.toString());
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(widget.place.lat, widget.place.lng),
      infoWindow: InfoWindow(title: widget.place.name),
    );

    setState(() {
      markers[markerId] = marker;
      // controller.setMapStyle('[{\"featureType\": \"poi\",\"stylers\": [{\"visibility\": \"off\"}]}]');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 220,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.place.lat, widget.place.lng),
                  zoom: 15.0,
                ),
                markers: Set<Marker>.of(markers.values),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
