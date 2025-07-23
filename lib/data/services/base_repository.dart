import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class baseRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  User? get currentUser => auth.currentUser;

  String get uid => currentUser?.uid ?? "";
  bool get isAuthenticated => currentUser != null;
}
