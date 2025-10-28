import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/posts_bloc/post_bloc.dart';
import '../data/models/post.dart';

class HomeScreen extends StatelessWidget {
  final String userId;
  HomeScreen({super.key, required this.userId});

  final TextEditingController _postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // --- Post Creation Widget ---
            BlocListener<PostBloc, PostState>(
              listener: (context, state) {
                if (state is PostCreationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post created successfully!')),
                  );
                  _postController.clear();
                } else if (state is PostCreationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Use BlocBuilder to show loading state on button
                  BlocBuilder<PostBloc, PostState>(
                    buildWhen: (previous, current) => current is PostCreationInProgress || previous is PostCreationInProgress,
                    builder: (context, state) {
                      final isPosting = state is PostCreationInProgress;
                      return IconButton(
                        icon: isPosting
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.send, color: Colors.blue),
                        onPressed: isPosting
                            ? null
                            : () {
                          if (_postController.text.isNotEmpty) {
                            context.read<PostBloc>().add(
                              CreatePost(_postController.text, userId),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // --- Real-time Post List Widget ---
            Expanded(
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is PostLoadInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is PostLoadFailure) {
                    return Center(child: Text('Failed to load posts: ${state.message}'));
                  }
                  if (state is PostLoadSuccess) {
                    print("Rendering ${state.posts.length} posts");
                    return ListView.builder(
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return PostListItem(post: post);
                      },
                    );
                  }
                  // PostInitial state
                  return const Center(child: Text('No posts yet!'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple widget to display a single post
class PostListItem extends StatelessWidget {
  final Post post;
  const PostListItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Posted by: ${post.username}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${post.timestamp.hour}:${post.timestamp.minute} on ${post.timestamp.month}/${post.timestamp.day}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// NOTE: Add LoginScreen and SignupScreen with appropriate BlocListeners/Builders for a complete app.