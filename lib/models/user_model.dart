class UserModel {
  final String id;
  final String email;
  final String? displayName; // depuis Firebase Auth
  final String? fullName;    // depuis Firestore
  final String? photoUrl;
  final String role;          // 'member' par défaut, 'admin' uniquement via Firestore console

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.fullName,
    this.photoUrl,
    this.role = 'collaborateur',
  });

  /// Nom affiché : priorité fullName (Firestore) > displayName (Auth) > partie avant l'@
  String get name => fullName ?? displayName ?? email.split('@').first;

  /// Vrai si le rôle est admin (attribué manuellement dans Firestore)
  bool get isAdmin => role == 'admin';

  // Factory depuis un utilisateur Firebase Auth
  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      fullName: null,
      photoUrl: user.photoURL,
      role: 'collaborateur', // Toujours collaborateur depuis Auth seul
    );
  }

  // Factory depuis un document Firestore
  factory UserModel.fromDocument(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? data['name'],
      fullName: data['fullName'],
      photoUrl: data['photoUrl'] ?? data['photoURL'] ?? data['avatar'],
      role: (data['role'] == null || data['role'] == 'member') ? 'collaborateur' : data['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}
