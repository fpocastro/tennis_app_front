import 'package:tennis_app_front/models/event_round.dart';

class EventGroup {
  String id;
  String name;
  List<EventRound> rounds;

  EventGroup.fromJson(Map<String, dynamic> data) {
    id = data['_id'];
    name = data['name'];
    rounds = data['rounds'].map((user) => EventRound.fromJson(user)).toList().cast<EventRound>();
  }
}
