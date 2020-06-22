import 'package:tennis_app_front/models/match_set.dart';
import 'package:tennis_app_front/models/place.dart';
import 'package:tennis_app_front/models/user.dart';

class Match {
  String id;
  User creator;
  String status;
  bool private;
  int numberOfPlayers;
  List<User> teamOne;
  List<User> teamTwo;
  DateTime creationDate;
  DateTime matchDate;
  List<Place> possiblePlaces;
  Place matchPlace;
  List<MatchSet> sets;

  Match.fromJson(Map<String, dynamic> data) {
    id = data['_id'];
    creator = User.fromJson(data['creator']);
    switch(data['status']) {
      case 'open': {
        status = 'Aberta';
      }
      break;
      case 'pending': {
        status = 'Em andamento';
      }
      break;
      case 'closed': {
        status = 'Finalizada';
      }
      break;
      default: {
        status = 'Finalizada';
      }
      break;
    }
    private = data['private'];
    numberOfPlayers = data['numberOfPlayers'];
    teamOne = data['teamOne'].map((user) => User.fromJson(user)).toList().cast<User>();
    teamTwo = data['teamTwo'].map((user) => User.fromJson(user)).toList().cast<User>();
    creationDate = data['creationDate'] == null || data['creationDate'] is DateTime ? data['creationDate'] : DateTime.parse(data['creationDate'].toString());
    matchDate = data['matchDate'] == null || data['matchDate'] is DateTime ? data['matchDate'] : DateTime.parse(data['matchDate'].toString());
    possiblePlaces = data['possiblePlaces'].map((place) => Place.fromJson(place)).toList().cast<Place>();
    matchPlace = data['matchPlace'] != null ? Place.fromJson(data['matchPlace']) : null;
    sets = data['score'] != null ? data['score']['sets'].map((matchSet) => MatchSet.fromJson(matchSet)).toList().cast<MatchSet>() : null;
  }
}
