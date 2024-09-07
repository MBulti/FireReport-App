import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthState { splash, authenticated, unauthenticated }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.splash);

  void checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    bool isLoggedIn = true;

    if (isLoggedIn) {
      emit(AuthState.authenticated); // Benutzer ist eingeloggt
    } else {
      emit(AuthState.unauthenticated); // Benutzer ist nicht eingeloggt
    }
  }

  void login(String userName, String password) {
    emit(AuthState.authenticated);
  }

  void guestLogin() {
    emit(AuthState.authenticated);
  }

  void logout() {
    emit(AuthState.unauthenticated);
  }
}
