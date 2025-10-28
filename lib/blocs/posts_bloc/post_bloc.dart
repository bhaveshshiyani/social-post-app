import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../data/models/post.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/posts_repository.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/post.dart';

part 'posts_event.dart';

part 'posts_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;
  late StreamSubscription _postsSubscription;

  PostBloc({
    required PostRepository postRepository,
    required AuthRepository authRepository,
  }) : _postRepository = postRepository,
       _authRepository = authRepository,
       super(PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<PostsUpdated>(_onPostsUpdated);
    on<CreatePost>(_onCreatePost);

    // Start listening to the stream immediately
    _postsSubscription = _postRepository.getPosts().listen(
      (posts) {
        add(PostsUpdated(posts));
      },
      onError: (error) {
        print('PostBloc Stream Error: $error');
        emit(PostLoadFailure('Real-time stream failed: $error'));
      },
    );
  }

  void _onLoadPosts(LoadPosts event, Emitter<PostState> emit) {
    emit(PostLoadInProgress());
    // The stream listener handles the rest
  }

  void _onPostsUpdated(PostsUpdated event, Emitter<PostState> emit) {
    // This handles the real-time push from the database
    emit(PostLoadSuccess(event.posts));
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    // 1. Get the current list of posts to modify it optimistically
    final currentState = state;
    final List<Post> existingPosts = currentState is PostLoadSuccess
        ? currentState.posts.toList()
        : [];

    try {
      // 2. Get the username
      final username = await _authRepository.getUsername(event.userId);

      // 3. Create an Optimistic Post (temporary ID is okay here)
      final optimisticPost = Post(
        id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
        message: event.message,
        username: username,
        uuid: event.userId,
        timestamp: DateTime.now(),
      );

      // 4. **OPTIMISTIC UPDATE:** Emit the new list immediately
      // This shows the post to the creator before the database confirms it.
      final updatedPosts = [optimisticPost, ...existingPosts];
      emit(PostLoadSuccess(updatedPosts));

      // Notify the UI that creation was initiated (e.g., to clear the text field)
      emit(PostCreationSuccess());

      // 5. Perform the asynchronous Firestore write
      await _postRepository.createPost(
        message: event.message,
        username: username,
        uuid: event.userId,
      );

      // The successful write will trigger the Firestore stream,
      // which sends PostsUpdated, replacing the optimistic list with the official one.
    } catch (e) {
      // 6. **REVERT/ROLLBACK** if the write fails
      // If the write fails, remove the optimistic post and return to the stable state.
      print('Post creation failed: $e');
      final revertedPosts = existingPosts;
      emit(PostLoadSuccess(revertedPosts));
      emit(PostCreationFailure('Failed to create post: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _postsSubscription.cancel();
    return super.close();
  }
}
