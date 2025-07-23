import 'dart:developer';
import 'package:chit_chat/data/models/user_models.dart';
import 'package:chit_chat/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends baseRepository {
  Stream<User?> get authStateChanges => auth.authStateChanges();
  Future<UserModels> signUp({
    required String fullname,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhoneNumber = phoneNumber.replaceAll(
        RegExp(r'\s+'),
        "".trim(),
      );

      final emailExits = await checkEmailExists(email);
      if (emailExits) {
        throw 'An account with the same email already exists';
      }
      final phoneExits = await checkPhoneExists(email);
      if (phoneExits) {
        throw 'An account with the same phone number already exists';
      }
      final UserCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (UserCredential.user == null) {
        throw 'Failed to create user';
      }

      //create user model and save user in the database.
      final user = UserModels(
        uid: auth.currentUser!.uid,
        username: username,
        fullname: fullname,
        email: email,
        phoneNumber: formattedPhoneNumber,
      );
      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> saveUserData(UserModels user) async {
    try {
      firebaseFirestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Failed to save your data';
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<UserModels> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (UserCredential.user == null) {
        throw 'User not Found';
      }
      final userData = await getUserData(UserCredential.user!.uid);
      return userData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      List<String> data = await auth.fetchSignInMethodsForEmail(email);
      return data.isNotEmpty;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final formattedPhoneNumber = phoneNumber.replaceAll(
        RegExp(r'\s+\'),
        "".trim(),
      );
      final querySnapshot = await firebaseFirestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhoneNumber)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('error checking email:$e');
      return false;
    }
  }

  Future<UserModels> getUserData(String uid) async {
    try {
      final document = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .get();
      if (!document.exists) {
        throw " User data not found";
      }
      log(document.id);
      return UserModels.fromFirestore(document);
    } catch (e) {
      throw 'Failed to save your data';
    }
  }
}
