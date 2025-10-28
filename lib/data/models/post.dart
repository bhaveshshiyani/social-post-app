import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String message;
  final String username;
  final String uuid;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.message,
    required this.username,
    required this.uuid,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      message: data['message'] ?? '',
      username: data['username'] ?? 'Unknown',
      uuid: data['uuid'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'username': username,
      'uuid': uuid,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}