import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_item.dart';
import '../models/user_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TaskItem>> getTasksStream(UserModel user) {
    Query query = _firestore.collection('tasks');
    if (!user.isAdmin) {
      query = query.where('assignedTo', isEqualTo: user.id);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskItem.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
    });
  }

  /// Crée une nouvelle tâche dans Firestore.
  /// Tous les champs sont préservés (priority, createdBy, comments inclus).
  Future<void> createTask(TaskItem task) async {
    try {
      final docRef = _firestore.collection('tasks').doc();
      final newTask = TaskItem(
        id: docRef.id,
        title: task.title,
        description: task.description,
        assignedTo: task.assignedTo,
        createdBy: task.createdBy,
        dueDate: task.dueDate,
        status: task.status,
        projectId: task.projectId,
        projectName: task.projectName,
        priority: task.priority,
        comments: task.comments,
      );
      await docRef.set(newTask.toMap());

      // Recalculer completionPercentage du projet après ajout
      if (task.projectId.isNotEmpty) {
        await _recalculateProjectCompletion(task.projectId);
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la tâche: $e');
    }
  }

  /// Met à jour le statut d'une tâche ET recalcule automatiquement
  /// le completionPercentage du projet associé.
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      // 1. Mettre à jour le statut de la tâche
      await _firestore.collection('tasks').doc(taskId).update({
        'status': newStatus,
      });

      // 2. Récupérer le projectId de la tâche
      final taskSnap = await _firestore.collection('tasks').doc(taskId).get();
      final projectId = (taskSnap.data()?['projectId'] as String?) ?? '';
      if (projectId.isEmpty) return;

      // 3. Recalculer + mettre à jour le projet
      await _recalculateProjectCompletion(projectId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Recalcule le completionPercentage d'un projet en fonction de ses tâches,
  /// et met à jour le statut du projet ('active' ou 'completed') en conséquence.
  Future<void> _recalculateProjectCompletion(String projectId) async {
    try {
      final allTasksSnap = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();

      final total = allTasksSnap.docs.length;
      if (total == 0) return;

      final doneCount = allTasksSnap.docs.where((d) {
        final s = ((d.data()['status']) as String? ?? '').toLowerCase();
        return s.contains('done');
      }).length;

      final percentage = ((doneCount / total) * 100).round();
      final projectStatus = percentage >= 100 ? 'completed' : 'active';

      await _firestore.collection('projects').doc(projectId).update({
        'completionPercentage': percentage,
        'status': projectStatus,
      });
    } catch (e) {
      print('Erreur _recalculateProjectCompletion: $e');
      // Ne pas planter l'app si la mise à jour du projet échoue
      // (ex: règle Firestore si l'utilisateur n'est pas créateur)
    }
  }

  /// Supprime une tâche et recalcule le completionPercentage du projet.
  Future<void> deleteTask(String taskId) async {
    try {
      final taskSnap = await _firestore.collection('tasks').doc(taskId).get();
      final projectId = (taskSnap.data()?['projectId'] as String?) ?? '';

      await _firestore.collection('tasks').doc(taskId).delete();

      if (projectId.isNotEmpty) {
        await _recalculateProjectCompletion(projectId);
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la tâche: $e');
    }
  }
  Future<void> addCommentToTask(String taskId, TaskComment comment) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du commentaire: $e');
    }
  }
}

