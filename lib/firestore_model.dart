import 'package:cloud_firestore/cloud_firestore.dart';

class AppFireStore {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('tokens');

  Future<void> addToken(token) {
    // Call the user's CollectionReference to add a new user
    return users
        .add({
          'token': token, // John Doe
        })
        .then((value) => print("token Added"))
        .catchError((error) => print("Failed to add token: $error"));
  }
}
