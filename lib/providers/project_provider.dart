import 'dart:async';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/user_model.dart';
import '../services/project_service.dart';
import '../services/user_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();

  List<Project> _projects = [];
  List<UserModel> _users = [];

  bool _projectsLoaded = false;
  bool _usersLoaded = false;

  String? _errorMessage;

  StreamSubscription? _projectsSub;
  StreamSubscription? _usersSub;

  UserModel? _currentUser;

  List<Project> get projects => _projects;
  List<UserModel> get users => _users;
  String? get errorMessage => _errorMessage;

  bool get isLoading => !(_projectsLoaded && _usersLoaded);

  ProjectProvider();

  void updateUser(UserModel? user) {
    if (_currentUser?.id != user?.id || _currentUser?.role != user?.role) {
      _currentUser = user;
      _restartListening();
    }
  }

  void _restartListening() {
    _projectsSub?.cancel();
    _usersSub?.cancel();

    if (_currentUser == null) {
      _projects = [];
      _users = [];
      _projectsLoaded = true;
      _usersLoaded = true;
      notifyListeners();
      return;
    }

    _projectsLoaded = false;
    _usersLoaded = false;
    notifyListeners();

    _projectsSub = _projectService.getProjectsStream(_currentUser!).listen(
      (data) {
        _projects = data;
        _projectsLoaded = true;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('ProjectProvider - stream error: $e');
        _projectsLoaded = true;
        _errorMessage = 'Erreur de connexion Firestore pour les projets.';
        notifyListeners();
      },
    );

    _usersSub = _userService.getUsersStream().listen(
      (data) {
        _users = data;
        _usersLoaded = true;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('ProjectProvider - Users stream error: $e');
        _usersLoaded = true;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _projectsSub?.cancel();
    _usersSub?.cancel();
    super.dispose();
  }
}
