// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

class LayoutState {
  final bool loading;
  final String? svgData;

  const LayoutState({this.loading = true, this.svgData});

  LayoutState copyWith({bool? loading, bool? phoneBoot, String? svgData}) {
    return LayoutState(loading: loading ?? this.loading, svgData: svgData ?? this.svgData);
  }
}

class LayoutController extends StateNotifier<LayoutState> {
  LayoutController() : super(LayoutState());

  Future<void> setInit() async {
    await loadSvg('assets/images/phone.svg');
  }

  Future<void> loadSvg(String assetPath) async {
    try {
      // SVG 문자열 읽기
      final svgString = await rootBundle.loadString(assetPath);
      // 로드 완료 시 loading false
      state = state.copyWith(loading: false, svgData: svgString);
    } catch (e) {
      // 실패 시에도 loading false로 바꾸고 로그 출력
      state = state.copyWith(loading: false);
      print("SVG 로드 실패: $e");
    }
  }
}

final layoutControllerProvider = StateNotifierProvider<LayoutController, LayoutState>((ref) {
  return LayoutController();
});
