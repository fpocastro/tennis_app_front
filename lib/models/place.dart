class Place {
  int id;
  String name;
  String website;
  String email;
  String phone;
  String pictureUlr;
  String fullAddress;
  double lat;
  double lng; 

  Place.fromJson(Map<String, dynamic> data) {
    name = data['name'];
    website = data['website'];
    email = data['email'];
    phone = data['phone'];
    pictureUlr = data['pictureUrl'];
    fullAddress = data['fullAddress'];
    lat = data['geo']['coordinates'][1];
    lng = data['geo']['coordinates'][0];
  }
}