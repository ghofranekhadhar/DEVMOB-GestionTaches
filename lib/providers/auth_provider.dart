import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Écoute des changements d'état d'authentification Firebase
    _authService.user.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Enrichir le UserModel depuis Firestore pour récupérer fullName
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
          if (doc.exists) {
            _user = UserModel.fromDocument(doc);
          } else {
            _user = UserModel.fromFirebaseUser(firebaseUser);
          }
        } catch (_) {
          _user = UserModel.fromFirebaseUser(firebaseUser);
        }
      } else {
        _user = null;
      }
      _setLoading(false);
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    _setLoading(true);
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(email, password);
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? email,
          'fullName': fullName,
          'role': 'member', // Rôle forcé — jamais choisi par l'utilisateur
          'avatar': '',
        });
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      // Pas besoin de reset _user ou _isLoading à false ici car 
      // la déconnexion déclenche le listener de `_authService.user` 
      // qui s'en chargera et appellera notifyListeners().
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
