import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/user_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskItem> _tasks = [];
  bool _tasksLoaded = false;

  StreamSubscription? _tasksSub;

  UserModel? _currentUser;

  List<TaskItem> get tasks => _tasks;
  bool get isLoading => !_tasksLoaded;

  TaskProvider();

  void updateUser(UserModel? user) {
    if (_currentUser?.id != user?.id || _currentUser?.role != user?.role) {
      _currentUser = user;
      _restartListening();
    }
  }

  void _restartListening() {
    _tasksSub?.cancel();

    if (_currentUser == null) {
      _tasks = [];
      _tasksLoaded = true;
      notifyListeners();
      return;
    }

    _tasksLoaded = false;
    notifyListeners();

    _tasksSub = _taskService.getTasksStream(_currentUser!).listen(
      (data) {
        _tasks = data;
        _tasksLoaded = true;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('TaskProvider - stream error: $e');
        _tasksLoaded = true;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }
}
