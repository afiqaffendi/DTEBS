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
      print('DEBUG: Starting signup for email: $email, role: $role');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        print('DEBUG: Firebase user created with UID: ${user.uid}');

        // Create User Model
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
        );

        // Save to Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        print('DEBUG: User data saved to Firestore');

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException during signup: ${e.code}');

      // Provide user-friendly error messages
      switch (e.code) {
        case 'weak-password':
          throw Exception(
            'The password is too weak. Please use at least 6 characters.',
          );
        case 'email-already-in-use':
          throw Exception(
            'This email is already registered. Please login instead.',
          );
        case 'invalid-email':
          throw Exception('Invalid email format. Please check and try again.');
        case 'operation-not-allowed':
          throw Exception(
            'Email/password accounts are not enabled. Please contact support.',
          );
        default:
          throw Exception('Registration failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      print('DEBUG: General error during signup: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
    return null;
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('DEBUG: Starting login for email: $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        print('DEBUG: Firebase authentication successful, UID: ${user.uid}');

        // Fetch User Data from Firestore to get Role
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          print('DEBUG: Firestore user data retrieved');
          UserModel userModel = UserModel.fromMap(
            doc.data() as Map<String, dynamic>,
            user.uid,
          );
          print('DEBUG: Login successful, user role: ${userModel.role}');
          return userModel;
        } else {
          print('DEBUG: User document not found in Firestore');
          throw Exception('User profile not found. Please contact support.');
        }
      }
    } on FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException during login: ${e.code}');

      // Provide user-friendly error messages
      switch (e.code) {
        case 'user-not-found':
          throw Exception(
            'No account found with this email. Please sign up first.',
          );
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'invalid-email':
          throw Exception('Invalid email format. Please check and try again.');
        case 'user-disabled':
          throw Exception(
            'This account has been disabled. Please contact support.',
          );
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later.');
        case 'invalid-credential':
          throw Exception(
            'Invalid credentials. Please check your email and password.',
          );
        default:
          throw Exception('Login failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      print('DEBUG: General error during login: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Login failed: ${e.toString()}');
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
