import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthState { splash, authenticated, anonymous, unauthenticated }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.splash);

  bool get isAnonymousUser {
    return state == AuthState.anonymous;
  }

  void checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Supabase.instance.client.auth.currentSession != null) {
      if (Supabase.instance.client.auth.currentUser!.isAnonymous) {
        emit(AuthState.anonymous);
      } else {
        emit(AuthState.authenticated);
      }
    } else {
      emit(AuthState.unauthenticated); // Benutzer ist nicht eingeloggt
    }
  }

  Future<void> login(String userName, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: userName,
        password: password,
      );
      emit(AuthState.authenticated);
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> guestLogin() async {
    try {
      await Supabase.instance.client.auth.signInAnonymously();
      emit(AuthState.anonymous);
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  void logout() {
    try {
      Supabase.instance.client.auth.signOut();
      emit(AuthState.unauthenticated);
    } on AuthException catch (e) {
      print(e.message);
    }
  }
}
