part of 'post_bloc.dart';

@immutable
abstract class PostEvent {}

class LoadPosts extends PostEvent {}

class PostsUpdated extends PostEvent {
  final List<Post> posts;
  PostsUpdated(this.posts);
}

class CreatePost extends PostEvent {
  final String message;
  final String userId; // Used to fetch username from AuthRepository
  CreatePost(this.message, this.userId);
}