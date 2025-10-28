import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/post.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final postsCollection = 'posts';

  // Real-time stream of posts
  Stream<List<Post>> getPosts() {
    return _firestore
        .collection(postsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // Save new post
  Future<void> createPost({required String message, required String username,required uuid}) async {
    final newPost = Post(
      id: '', // Firestore generates ID
      message: message,
      username: username,
      uuid: uuid,
      timestamp: DateTime.now(),
    );
    await _firestore.collection(postsCollection).add(newPost.toFirestore());
  }
}