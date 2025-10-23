import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:utility/import_package.dart';

class LoginState {
  final String id;
  final String password;
  final String wrongMessage;
  final bool confirm; // id & pw 입력 여부 bool

  LoginState({this.id = '', this.password = '', this.wrongMessage = '', this.confirm = false});

  LoginState copyWith({String? id, String? password, String? wrongMessage, bool? confirm}) {
    return LoginState(
      id: id ?? this.id,
      password: password ?? this.password,
      wrongMessage: wrongMessage ?? this.wrongMessage,
      confirm: confirm ?? this.confirm,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(LoginState());

  void setInputData(String type, String value) {
    if (type == 'id') {
      state = state.copyWith(id: value);
    } else if (type == 'password') {
      state = state.copyWith(password: value);
    }
    state = state.copyWith(confirm: state.id != '' && state.password != '');
  }

  Future<void> login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: state.id, password: state.password);
      state = state.copyWith(wrongMessage: '');
      context.push('/');
    } catch (e) {
      state = state.copyWith(wrongMessage: '아이디 혹은 비밀번호가 존재하지 않습니다.');
    }
  }
}

final loginControllerProvider = StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController();
});
