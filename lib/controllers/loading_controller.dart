// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

class LoadingState {
  final bool phoneBoot;
  final int loadingPercent;

  const LoadingState({this.phoneBoot = false, this.loadingPercent = 0});

  LoadingState copyWith({bool? phoneBoot, int? loadingPercent}) {
    return LoadingState(phoneBoot: phoneBoot ?? this.phoneBoot, loadingPercent: loadingPercent ?? this.loadingPercent);
  }
}

class LoadingController extends StateNotifier<LoadingState> {
  LoadingController() : super(LoadingState());

  Future<void> setLoading(BuildContext context) async {
    await loadingIndicatior();
    await Future.delayed(const Duration(milliseconds: 200));
    if (state.loadingPercent == 100) {
      state = state.copyWith(phoneBoot: true);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (context.mounted) context.go('/');
  }

  // 로딩 페이지를 거치지 않고(새로고침 등) phone 화면으로 바로 진입한 경우 부팅 상태로 처리
  void bootPhone() {
    if (!state.phoneBoot) {
      state = state.copyWith(phoneBoot: true);
    }
  }

  void initLogout() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> loadingIndicatior() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 10), () {
        state = state.copyWith(loadingPercent: i);
      });
    }
  }
}

final loadingControllerProvider = StateNotifierProvider<LoadingController, LoadingState>((ref) {
  return LoadingController();
});
