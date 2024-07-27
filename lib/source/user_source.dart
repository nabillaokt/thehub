import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:thehub/config/session.dart';
import '../model/user.dart';

class UserSource {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    Map<String, dynamic> response = {};
    try {
      final credential = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      response['success'] = true;
      response['message'] = 'Sign In Success';
      String uid = credential.user!.uid;
      User user = await getWhereId(uid);
      Session.saveUser(user);
    } on auth.FirebaseAuthException catch (e) {
      response['success'] = false;

      if (e.code == 'user-not-found') {
        response['message'] = 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        response['message'] = 'Wrong password provided for that user';
      } else {
        response['message'] = 'Sign in failed';
      }
    }
    return response;
  }

  static Future<User> getWhereId(String id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('user').doc(id).get();
    return User.fromJson(doc.data()!);
  }

  static Future<bool> checkIfEmailExists(String email) async {
    final querySnapshot = await _firestore
        .collection('user')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  static Future<Map<String, dynamic>> registerUser(
    String email,
    String password,
    String name,
    String dateOfBirth,
    String avatar,
    String gender,
    String balance,
    // add more fields as required for user registration
  ) async {
    Map<String, dynamic> response = {};
    try {
      // Check if email already exists
      bool emailExists = await checkIfEmailExists(email);
      if (emailExists) {
        response['success'] = false;
        response['message'] = 'Email already in use';
        return response;
      }

      final auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a map to store user data
      Map<String, dynamic> userData = {
        'email': email,
        'name': name,
        'password': password,
        'dateOfBirth': dateOfBirth,
        'avatar': avatar,
        'gender': gender,
        'balance': '0'
        // add more fields as required for user registration
      };

      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userCredential.user!.uid)
          .set(userData);

      response['success'] = true;
      response['message'] = 'Registration successful';
    } catch (e) {
      response['success'] = false;
      response['message'] = 'Registration failed';
    }
    return response;
  }

  static Future<void> logout() async {
    try {
      await auth.FirebaseAuth.instance.signOut();
      Session.clearSession(); // Clear saved user session data
    } catch (e) {
      // Handle error
      rethrow; // Rethrow the exception for handling in UI or upper layers
    }
  }
}
