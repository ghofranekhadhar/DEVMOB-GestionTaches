import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/user_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Project>> getProjectsStream(UserModel user) {
    Query query = _firestore.collection('projects');
    if (!user.isAdmin) {
      query = query.where('members', arrayContains: user.id);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Project.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
    });
  }

  /// Crée un nouveau projet dans Firestore.
  Future<void> createProject(Project project) async {
    try {
      DocumentReference docRef;
      if (project.id.isEmpty) {
        docRef = _firestore.collection('projects').doc();
        final newProject = Project(
          id: docRef.id,
          name: project.name,
          description: project.description,
          deadline: project.deadline,
          members: project.members,
          createdBy: project.createdBy,
          status: project.status,
          completionPercentage: project.completionPercentage,
        );
        await docRef.set(newProject.toMap());
      } else {
        await _firestore.collection('projects').doc(project.id).set(project.toMap());
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du projet: $e');
    }
  }

  /// Met à jour un projet existant (réservé au créateur via Firestore rules).
  Future<void> updateProject(Project project) async {
    try {
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(project.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du projet: $e');
    }
  }

  /// Supprime un projet et toutes ses tâches associées.
  Future<void> deleteProject(String projectId) async {
    try {
      // Supprimer toutes les tâches du projet
      final tasks = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      for (final doc in tasks.docs) {
        await doc.reference.delete();
      }
      // Supprimer le projet
      await _firestore.collection('projects').doc(projectId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du projet: $e');
    }
  }
}
