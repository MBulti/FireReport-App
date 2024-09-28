import 'package:firereport/models/models.dart';
import 'package:firereport/utils/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthState { splash, loading, authenticated, anonymous, unauthenticated, error }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.splash);

  bool get isAnonymousUser {
    return state == AuthState.anonymous;
  }

  AppUser get user {
    return APIClient.currentUser ?? AppUser(id: "", firstName: "Gast", lastName: "");
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    if (Supabase.instance.client.auth.currentSession != null) {
      if (Supabase.instance.client.auth.currentSession!.user.isAnonymous) {
        emit(AuthState.anonymous);
      } else {
        APIClient.setCurrentUser(Supabase.instance.client.auth.currentUser!);
        emit(AuthState.authenticated);
      }
    } else {
      emit(AuthState.unauthenticated);
    }
  }

  Future<void> login(String userName, String password) async {
    try {
      emit(AuthState.loading);
      await APIClient.login(userName, password);
      emit(AuthState.authenticated);
    } on AuthException {
      emit(AuthState.error);
    }
  }

  Future<void> guestLogin() async {
    try {
      emit(AuthState.loading);
      await APIClient.loginAnonymously();
      emit(AuthState.anonymous);
    } on AuthException {
      emit(AuthState.error);
    }
  }

  Future<void> logout() async {
    try {
      await APIClient.logout();
      emit(AuthState.unauthenticated);
    } on AuthException {
      emit(AuthState.error);
    }
  }
}
