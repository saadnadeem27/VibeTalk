import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool isOnline;
  final DateTime? lastSeen;
  final String status;
  final List<String> blockedUsers;
  final bool showLastSeen;
  final bool readReceipts;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.isOnline = false,
    this.lastSeen,
    this.status = 'Hey there! I am using VibeTalk.',
    this.blockedUsers = const [],
    this.showLastSeen = true,
    this.readReceipts = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen']?.toDate(),
      status: data['status'] ?? 'Hey there! I am using VibeTalk.',
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
      showLastSeen: data['showLastSeen'] ?? true,
      readReceipts: data['readReceipts'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'status': status,
      'blockedUsers': blockedUsers,
      'showLastSeen': showLastSeen,
      'readReceipts': readReceipts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? isOnline,
    DateTime? lastSeen,
    String? status,
    List<String>? blockedUsers,
    bool? showLastSeen,
    bool? readReceipts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      readReceipts: readReceipts ?? this.readReceipts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
