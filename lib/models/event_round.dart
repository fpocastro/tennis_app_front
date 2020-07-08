import 'package:tennis_app_front/models/match.dart';

class EventRound {
  String id;
  String name;
  List<Match> matches;

  EventRound.fromJson(Map<String, dynamic> data) {
    id = data['_id'];
    name = data['name'];
    matches = data['matches'].map((match) => Match.fromJson(match)).toList().cast<Match>();
  }
}
