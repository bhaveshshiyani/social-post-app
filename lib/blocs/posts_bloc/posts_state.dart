part of 'post_bloc.dart';

@immutable
abstract class PostState {}

class PostInitial extends PostState {}

class PostLoadSuccess extends PostState {
  final List<Post> posts;
  PostLoadSuccess(this.posts);
}

class PostLoadInProgress extends PostState {}

class PostLoadFailure extends PostState {
  final String message;
  PostLoadFailure(this.message);
}

class PostCreationInProgress extends PostState {}

class PostCreationSuccess extends PostState {}

class PostCreationFailure extends PostState {
  final String message;
  PostCreationFailure(this.message);
}