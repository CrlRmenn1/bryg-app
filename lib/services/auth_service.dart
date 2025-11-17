import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ---------------- SIGN UP (Create Account) ----------------
  static Future<String?> signup({
    required String fullname,
    required String address,
    required String cellphone,
    required String email,
    required String birthday,
    required String password,
    required String position,
  }) async {
    try {
      // Create auth user
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user profile data
      await _db.collection("users").doc(userCred.user!.uid).set({
        "fullname": fullname,
        "address": address,
        "cellphone": cellphone,
        "email": email,
        "birthday": birthday,
        "position": position,
        "createdAt": DateTime.now(),
      });

      return null; // SUCCESS
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// ---------------- LOGIN ----------------
  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // SUCCESS
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// ---------------- LOGOUT ----------------
  static Future<void> logout() async {
    await _auth.signOut();
  }
}
