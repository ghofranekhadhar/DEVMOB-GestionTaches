import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String deadline;
  final List<String> members;
  final String createdBy;
  final String status;
  final int completionPercentage;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.members,
    required this.createdBy,
    required this.status,
    this.completionPercentage = 0,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      deadline: data['deadline'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdBy: data['createdBy'] ?? '',
      status: data['status'] ?? '',
      completionPercentage: data['completionPercentage'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'deadline': deadline,
      'members': members,
      'createdBy': createdBy,
      'status': status,
      'completionPercentage': completionPercentage,
    };
  }
}
