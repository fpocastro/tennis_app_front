class User {
  String uid;
  String name;
  String email;
  DateTime dateOfBirth;
  int height;
  int weight;
  String laterality;
  String backhand;
  String court;
  String pictureUrl;
  double level;
  int playersSearchDistance;
  int placesSearchDistance;
  bool introduction;

  User.fromJson(Map<String, dynamic> data) {
    uid = data['_id'];
    name = data['name'];
    email = data['email'];
    dateOfBirth = data['dateOfBirth'] != null ? DateTime.parse( data['dateOfBirth']) : null;
    height = data['height'];
    weight = data['weight'];
    laterality = data['laterality'];
    backhand = data['backhand'];
    court = data['court'];
    pictureUrl = data['pictureUrl'];
    level = data['level'] == null || data['level'] is double ? data['level'] : data['level'].toDouble();
    playersSearchDistance = data['playersSearchDistance'];
    placesSearchDistance = data['placesSearchDistance'];
    introduction = data['introduction'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> user = {};
    user['uid'] = this.uid;
    user['name'] = this.name;
    user['email'] = this.email;
    user['dateOfBirth'] = this.dateOfBirth.toString();
    user['height'] = this.height;
    user['weight'] = this.weight;
    user['laterality'] = this.laterality;
    user['backhand'] = this.backhand;
    user['court'] = this.court;
    user['pictureUrl'] = this.pictureUrl;
    user['level'] = this.level;
    user['playersSearchDistance'] = this.playersSearchDistance;
    user['placesSearchDistance'] = this.placesSearchDistance;
    user['introduction'] = this.introduction;

    return user;
  }

  Map<String, dynamic> toJsonRequest() {
    Map<String, dynamic> user = {};
    user['name'] = this.name;
    if (this.dateOfBirth != null) user['dateOfBirth'] = this.dateOfBirth.toString();
    if (this.height != null) user['height'] = this.height;
    if (this.weight != null) user['weight'] = this.weight;
    if (this.laterality != null) user['laterality'] = this.laterality;
    if (this.backhand != null) user['backhand'] = this.backhand;
    if (this.court != null) user['court'] = this.court;
    if (this.level != null) user['level'] = this.level;
    if (this.playersSearchDistance != null) user['playersSearchDistance'] = this.playersSearchDistance;
    if (this.placesSearchDistance != null) user['placesSearchDistance'] = this.placesSearchDistance;
    if (this.introduction != null) user['introduction'] = this.introduction;

    return user;
  }
}
