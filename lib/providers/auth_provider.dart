import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRole _currentRole = UserRole.patient;
  UserModel? _currentUser;

  bool _isLoading = false;
  String? _errorMessage;

  late final StreamSubscription<User?> _authSubscription;

  AuthProvider() {
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthStateChanged,
    );
  }

  // ---------------- GETTERS ----------------

  UserRole get currentRole => _currentRole;

  UserModel? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _auth.currentUser != null;

  // ---------------- AUTH STATE ----------------

  Future<void> _handleAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _currentRole = UserRole.patient;

      notifyListeners();
      return;
    }

    try {
      await _loadUserFromFirestore(firebaseUser.uid);
    } catch (e) {
      debugPrint('Failed to restore user session: $e');
    }
  }

  // ---------------- REGISTER ----------------

  Future<bool> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw StateError('Firebase did not return a user.');
      }

      final userData = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),

        // IMPORTANT:
        // Public registration can ONLY create patients.
        'role': 'patient',

        'avatarUrl': '',
        'clinicId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userData);
      } catch (e) {
        // If Firestore creation fails, don't leave an incomplete
        // Firebase Auth account behind.
        await firebaseUser.delete();
        rethrow;
      }

      await _loadUserFromFirestore(firebaseUser.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseAuthErrorMessage(e);
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');

      _errorMessage =
          'Could not create your account. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- LOGIN ----------------

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw StateError('Firebase did not return a user.');
      }

      await _loadUserFromFirestore(firebaseUser.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseAuthErrorMessage(e);
      return false;
    } on StateError catch (e) {
      debugPrint('Login profile error: $e');

      await _auth.signOut();

      _errorMessage =
          'Your account profile could not be found.';

      return false;
    } catch (e) {
      debugPrint('Login error: $e');

      _errorMessage =
          'Could not log in. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- LOAD USER ----------------

  Future<void> _loadUserFromFirestore(String uid) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      throw StateError(
        'No Firestore user document exists for $uid',
      );
    }

    final data = document.data();

    if (data == null) {
      throw StateError(
        'Firestore user document contains no data.',
      );
    }

    final role = _roleFromString(
      data['role'] as String? ?? 'patient',
    );

    _currentRole = role;

    _currentUser = UserModel(
      id: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: role,
      phone: data['phone'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
    );

    notifyListeners();
  }
Future<bool> restoreSession() async {
  final firebaseUser = _auth.currentUser;

  if (firebaseUser == null) {
    _currentUser = null;
    _currentRole = UserRole.patient;
    return false;
  }

  _setLoading(true);
  _errorMessage = null;

  try {
    await _loadUserFromFirestore(firebaseUser.uid);
    return true;
  } catch (e) {
    debugPrint('Restore session error: $e');

    await _auth.signOut();

    _currentUser = null;
    _currentRole = UserRole.patient;

    _errorMessage = 'Could not restore your session.';

    return false;
  } finally {
    _setLoading(false);
  }
}
  // ---------------- LOGOUT ----------------

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _auth.signOut();

      _currentUser = null;
      _currentRole = UserRole.patient;
    } catch (e) {
      debugPrint('Logout error: $e');

      _errorMessage =
          'Could not log out. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- HELPERS ----------------

  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;

      case 'assistant':
        return UserRole.assistant;

      case 'patient':
      default:
        return UserRole.patient;
    }
  }

  String _firebaseAuthErrorMessage(
    FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account exists with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return exception.message ??
            'Authentication failed. Please try again.';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --------------------------------------------------
  // TEMPORARY LEGACY METHOD
  //
  // Keep this ONLY until we connect your existing
  // login/register screens in the next step.
  // Then we will remove it completely.
  // --------------------------------------------------

  void setRole(UserRole role) {
    _currentRole = role;

    _currentUser = switch (role) {
      UserRole.patient => const UserModel(
          id: 'u1',
          name: 'Hend Aboelouon',
          email: 'hend.aboelouon@example.com',
          role: UserRole.patient,
          phone: '01102177734',
          avatarUrl: '',
        ),
      UserRole.assistant => const UserModel(
          id: 'u2',
          name: 'Sara Al-Khalid',
          email: 'sara@example.com',
          role: UserRole.assistant,
          phone: '01100000000',
          avatarUrl: '',
        ),
      UserRole.admin => const UserModel(
          id: 'u3',
          name: 'Platform Admin',
          email: 'admin@dorakk.com',
          role: UserRole.admin,
          phone: '01111111111',
          avatarUrl: '',
        ),
    };

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}