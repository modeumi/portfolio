import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

class LoginState {
  final String id;
  final String password;
  final String wrongMessage;
  final bool confirm; // id & pw 입력 여부 bool
  final bool loading;

  LoginState({this.id = '', this.password = '', this.wrongMessage = '', this.confirm = false, this.loading = false});

  LoginState copyWith({String? id, String? password, String? wrongMessage, bool? confirm, bool? loading}) {
    return LoginState(
      id: id ?? this.id,
      password: password ?? this.password,
      wrongMessage: wrongMessage ?? this.wrongMessage,
      confirm: confirm ?? this.confirm,
      loading: loading ?? this.loading,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(LoginState());

  final auth = FirebaseAuth.instance;

  void resetState() {
    state = state.copyWith(id: '', password: '', confirm: false, wrongMessage: '');
  }

  void initState(BuildContext context) {
    User? user = auth.currentUser;
    if (user != null) {
      context.go('/manage');
    }
  }

  void setInputData(String type, String value) {
    if (type == 'id') {
      state = state.copyWith(id: value);
    } else if (type == 'password') {
      state = state.copyWith(password: value);
    }
    state = state.copyWith(confirm: state.id != '' && state.password != '');
  }

  Future<void> login(BuildContext context) async {
    state = state.copyWith(loading: false);
    try {
      await auth.signInWithEmailAndPassword(email: state.id, password: state.password);

      state = state.copyWith(wrongMessage: '');

      context.go('/manage');
    } catch (e) {
      state = state.copyWith(wrongMessage: '아이디 혹은 비밀번호가 존재하지 않습니다.');
    }
    state = state.copyWith(loading: true);
  }

  Future<void> logout(BuildContext context) async {
    await auth.signOut();
    context.go('/login');
  }
}

final loginControllerProvider = StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController();
});
