import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {

    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    // 1. LoggedOut is for stream notification ONLY
    on<LoggedOut>(_onLoggedOut);
    // 2. SignOutRequested is for UI action
    on<SignOutRequested>(_onSignOutRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);

    _userSubscription = _authRepository.user.listen((user) {
      add(user != null ? LoggedIn(user) : LoggedOut());
    });
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    // Handled by the stream subscription
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user.uid));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthUnauthenticated());
  }
  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    print('AuthBloc: SignOutRequested (UI) -> Calling AuthRepository.logOut()');
    await _authRepository.logOut();
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        username: event.username,
      );
      // LoggedIn event will be triggered by the stream
    } catch (e) {
      emit(AuthError(e.toString()));
      // Reset state to Unauthenticated on error
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _authRepository.logIn(
        email: event.email,
        password: event.password,
      );
      print("user : ${cred.user?.uid}");
      final user = cred.user!;
      emit(AuthAuthenticated(user.uid));
    } catch (e) {
      print("user : ${e.toString()} ${e}");
      emit(AuthError("Invalid email or password. Please try again."));
      // Reset state to Unauthenticated on error
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}