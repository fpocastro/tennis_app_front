import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference placeCollection = Firestore.instance.collection('places');

  Future getUserData() async {
    return await userCollection.document(uid).get();
  }

  Future updateUserData(String name, int dateOfBirth, int height,
      int weight, String laterality, String backhand, String court) async {
    return await userCollection.document(uid).setData({
      'name': name,
      'dateOfBirth': dateOfBirth,
      'height': height,
      'weight': weight,
      'laterality': laterality,
      'backhand': backhand,
      'court': court,
    });
  }

  Future getPlaces() async {
    return await placeCollection.getDocuments();
  }
}
