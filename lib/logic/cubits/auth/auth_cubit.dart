import 'dart:async';
import 'package:chit_chat/data/repositories/auth_repository.dart';
import 'package:chit_chat/data/repositories/chat_repository.dart';
import 'package:chit_chat/logic/cubits/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;
  final ChatRepository? _chatRepository;

  AuthCubit({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       _chatRepository = chatRepository,
       super(const AuthState()) {
    _init();
  }
  void _init() {
    emit(state.copyWith(status: AuthStatus.initial));
    _authStateSubscription = _authRepository.authStateChanges.listen((
      user,
    ) async {
      if (user != null) {
        try {
          final userData = await _authRepository.getUserData(user.uid);
          emit(
            state.copyWith(status: AuthStatus.authenticated, user: userData),
          );
        } catch (e) {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      } else {
        // 👇 This was missing
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullname,
    required String phoneNumber,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signUp(
        fullname: fullname,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      if (state.user != null)
        await _chatRepository?.updateOnlineStatus(state.user!.uid, false);
      await _authRepository.signOut();
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }
}
