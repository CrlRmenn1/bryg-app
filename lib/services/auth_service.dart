import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Current Firebase user (null if not logged in)
  static User? get currentUser => _auth.currentUser;

  /// Listen for login / logout changes
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// ---------------- SIGN UP (Create Account) ----------------
  ///
  /// Returns:
  ///   null  -> success
  ///   error -> error message string
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
      // 1) Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;

      // 2) Decide role from position
      // You can tweak this mapping if needed.
      String role;
      if (position.toLowerCase() == 'resident') {
        role = 'resident';
      } else {
        // Example: Barangay Captain, Purok Leader, etc = admin-level
        role = 'admin';
      }

      // 3) Save user profile in Firestore
      await _db.collection('users').doc(uid).set({
        'fullname': fullname,
        'address': address,
        'cellphone': cellphone,
        'email': email,
        'birthday': birthday,
        'position': position,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // SUCCESS
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// ---------------- LOGIN ----------------
  ///
  /// Returns:
  ///   null  -> success
  ///   error -> error message string
  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
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

  /// ---------------- GET CURRENT USER PROFILE ----------------
  ///
  /// Returns Firestore user document data for the current user,
  /// or null if not logged in or document missing.
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  /// ---------------- CHECK IF CURRENT USER IS ADMIN ----------------
  ///
  /// Uses `role` field primarily, but also falls back to `position`.
  static Future<bool> isCurrentUserAdmin() async {
    final profile = await getCurrentUserProfile();
    if (profile == null) return false;

    final role = (profile['role'] ?? '').toString().toLowerCase();
    final position = (profile['position'] ?? '').toString().toLowerCase();

    if (role == 'admin') return true;

    // Fallback on position keywords (you can adjust)
    if (position.contains('captain')) return true;
    if (position.contains('leader')) return true;
    if (position.contains('kagawad')) return true;

    return false;
  }
}
