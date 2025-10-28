import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social_post_app/repositories/auth_repository.dart';
import 'package:social_post_app/repositories/posts_repository.dart';
import 'package:social_post_app/ui/home_page.dart';
import 'package:social_post_app/ui/login_page.dart';

import 'blocs/auth_bloc/auth_bloc.dart';
import 'blocs/posts_bloc/post_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  final authRepository = AuthRepository();
  final postRepository = PostRepository();

  runApp(MyApp(
    authRepository: authRepository,
    postRepository: postRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final PostRepository postRepository;

  const MyApp({super.key, required this.authRepository, required this.postRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: postRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)..add(AppStarted()),
          ),
          // PostBloc is only created and provided on the Home Screen
          // BlocProvider<PostBloc>(
          //   create: (context) => PostBloc(postRepository: postRepository, authRepository: authRepository),
          // ),
        ],
        child: MaterialApp(
          title: 'Social Post',
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                // Pass the AuthRepository to PostBloc
                return BlocProvider(
                  create: (context) => PostBloc(
                    postRepository: postRepository,
                    authRepository: authRepository,
                  ),
                  child: HomeScreen(userId: state.userId),
                );
              }
              if (state is AuthUnauthenticated || state is AuthError || state is AuthLoading) {
                // Simple navigation logic, typically you'd use a Navigator
                return const LoginScreen();
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }
}