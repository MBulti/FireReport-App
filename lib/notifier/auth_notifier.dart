import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/models/models.dart';
import 'package:firereport/utils/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthState {
  splash,
  loading,
  authenticated,
  anonymous,
  unauthenticated,
  error
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.splash);

  // Determine if the user is anonymous
  bool get isAnonymousUser {
    return state == AuthState.anonymous;
  }

  // Get the current user or a default guest user
  AppUser get user {
    return APIClient.currentUser ??
        AppUser(id: "", firstName: "Gast", lastName: "");
  }

  // Check the login status of the user
  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    if (Supabase.instance.client.auth.currentSession != null) {
      if (Supabase.instance.client.auth.currentSession!.user.isAnonymous) {
        state = AuthState.anonymous;
      } else {
        APIClient.setCurrentUser(Supabase.instance.client.auth.currentUser!);
        state = AuthState.authenticated;
      }
    } else {
      state = AuthState.unauthenticated;
    }
  }

  // Handle user login
  Future<void> login(String userName, String password) async {
    try {
      state = AuthState.loading;
      await APIClient.login(userName, password);
      state = AuthState.authenticated;
    } on AuthException {
      state = AuthState.error;
    }
  }

  // Handle guest login
  Future<void> guestLogin() async {
    try {
      state = AuthState.loading;
      await APIClient.loginAnonymously();
      state = AuthState.anonymous;
    } on AuthException catch (e) {
      state = AuthState.error;
      await APIClient.addLog(e.toString());
    }
  }

  // Handle logout
  Future<void> logout() async {
    try {
      await APIClient.logout();
      state = AuthState.unauthenticated;
    } on AuthException catch (e) {
      state = AuthState.error;
      await APIClient.addLog(e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// FutureProvider to trigger checkLoginStatus at the start
final authCheckProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).checkLoginStatus();
});