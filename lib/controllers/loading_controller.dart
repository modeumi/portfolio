// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    context.go('/');
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
