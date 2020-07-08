import 'package:tennis_app_front/models/event_group.dart';
import 'package:tennis_app_front/models/match_set.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/models/user.dart';

class Event {
  String id;
  User creator;
  String status;
  bool private;
  String name;
  List<User> participants;
  Place place;
  List<EventGroup> groups;
  DateTime creationDate;

  Event.fromJson(Map<String, dynamic> data) {
    id = data['_id'];
    creator = User.fromJson(data['creator']);
    status = data['status'];
    private = data['private'];
    name = data['name'];
    participants = data['participants'].map((user) => User.fromJson(user)).toList().cast<User>();
    place = Place.fromJson(data['place']);
    groups = data['groups'].map((user) => EventGroup.fromJson(user)).toList().cast<EventGroup>();
    creationDate = DateTime.parse(data['creationDate'].toString());
  }
}
