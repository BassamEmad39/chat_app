import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial()) {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      emit(AuthUnAuthenticated());
    } else {
      try {
        // Get user data from Firestore
        final userDoc = await _firestore.collection('Users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          final user = UserModel.fromMap(userDoc.data()!);
          emit(AuthAuthenticated(user));
        } else {
          // This shouldn't happen, but if it does, sign out
          await _auth.signOut();
          emit(AuthUnAuthenticated());
        }
      } catch (e) {
        emit(AuthError('Failed to get user data: $e'));
      }
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(AuthLoading());
    try {
      // Check if username already exists
      final usernameQuery = await _firestore
          .collection('Users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        emit(AuthError('Username already taken. Please choose another one.'));
        return;
      }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        username: username,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('Users').doc(user.uid).set(user.toMap());
      
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError('Registration failed: $e'));
    }
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // State will be updated by authStateChanges listener
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError('Login failed: $e'));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // State will be updated by authStateChanges listener
  }

  UserModel? get currentUser {
    return state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;
  }
}