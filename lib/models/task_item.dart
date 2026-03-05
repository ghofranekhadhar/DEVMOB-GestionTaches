import 'package:cloud_firestore/cloud_firestore.dart';

class TaskComment {
  final String id;
  final String user;
  final String text;
  final String date;

  TaskComment({
    required this.id,
    required this.user,
    required this.text,
    required this.date,
  });

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      id: map['id'] ?? '',
      user: map['user'] ?? '',
      text: map['text'] ?? '',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'text': text,
      'date': date,
    };
  }
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String assignedTo;  // UID Firebase Auth uniquement
  final String createdBy;   // UID de celui qui a créé la tâche
  final String dueDate;
  final String status;      // 'To Do' | 'In Progress' | 'Done'
  final String projectId;
  final String projectName;
  final String priority;    // 'low' | 'medium' | 'high' | 'urgent'
  final List<TaskComment> comments;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    this.createdBy = '',
    required this.dueDate,
    required this.status,
    required this.projectId,
    this.projectName = '',
    this.priority = 'medium',
    this.comments = const [],
  });

  factory TaskItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      createdBy: data['createdBy'] ?? '',
      dueDate: data['dueDate'] ?? '',
      status: data['status'] ?? 'To Do',
      projectId: data['projectId'] ?? '',
      projectName: data['projectName'] ?? '',
      priority: data['priority'] ?? 'medium',
      comments: (data['comments'] as List? ?? [])
          .map((c) => TaskComment.fromMap(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'dueDate': dueDate,
      'status': status,
      'projectId': projectId,
      'projectName': projectName,
      'priority': priority,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }
}
