class MatchSet {
  int teamOne;
  int teamTwo;
  int teamOneTiebreak;
  int teamTwoTiebreak;
  bool hasTiebreak;

  MatchSet.fromJson(Map<String, dynamic> data) {
    teamOne = data['teamOne'];
    teamTwo = data['teamTwo'];
    if (data['teamOneTiebreak'] != null) teamOneTiebreak = data['teamOneTiebreak'];
    if (data['teamTwoTiebreak'] != null) teamTwoTiebreak = data['teamTwoTiebreak'];
    if (data['teamOneTiebreak'] != null && data['teamTwoTiebreak'] != null) hasTiebreak = true; else hasTiebreak = false;
  }
}