import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create User Model
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
        );

        // Save to Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        return newUser;
      }
    } catch (e) {
      print('SignUp Error: $e');
      rethrow;
    }
    return null;
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Fetch User Data from Firestore to get Role
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return UserModel.fromMap(
            doc.data() as Map<String, dynamic>,
            user.uid,
          );
        }
      }
    } catch (e) {
      print('SignIn Error: $e');
      rethrow;
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
