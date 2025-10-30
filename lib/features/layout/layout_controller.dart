// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/features/home/home_controller.dart';
import 'package:portfolio/features/message/message_controller.dart';
import 'package:utility/format.dart';

class LayoutState {
  final bool loading;
  final bool power;
  final bool statusOpen;
  final bool colorType;

  final String? svgData;
  final String clock;

  final double startDy;
  final double endDy;
  final double valueDy;
  final double statusOpacity;

  const LayoutState({
    this.loading = true,
    this.power = true,
    this.statusOpen = false,
    this.colorType = false,

    this.svgData,
    this.clock = '',

    this.startDy = 0.0,
    this.endDy = 0.0,
    this.valueDy = 0.0,
    this.statusOpacity = 0.0,
  });

  LayoutState copyWith({
    bool? loading,
    bool? power,
    bool? statusOpen,
    bool? colorType,
    String? svgData,
    String? clock,
    double? startDy,
    double? endDy,
    double? valueDy,
    double? statusOpacity,
  }) {
    return LayoutState(
      loading: loading ?? this.loading,
      power: power ?? this.power,
      svgData: svgData ?? this.svgData,
      colorType: colorType ?? this.colorType,
      clock: clock ?? this.clock,
      statusOpen: statusOpen ?? this.statusOpen,
      startDy: startDy ?? this.startDy,
      endDy: endDy ?? this.endDy,
      valueDy: valueDy ?? this.valueDy,
      statusOpacity: statusOpacity ?? this.statusOpacity,
    );
  }
}

class LayoutController extends StateNotifier<LayoutState> {
  final Ref ref;
  LayoutController(this.ref) : super(LayoutState());

  Future<void> setPhoneInit() async {
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

  void setClock() async {
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      final now = DateTime.now();
      final formattedTime = time_to_string_HHmm(now);
      state = state.copyWith(clock: formattedTime);
    });
  }

  void setPower(bool power) {
    if (power) {
      state = state.copyWith(power: true);
    } else {
      state = state.copyWith(power: false, valueDy: 0.0, statusOpen: false, statusOpacity: 0.0);
    }
  }

  void tapHome() {
    state = state.copyWith(valueDy: 0.0, statusOpen: false, statusOpacity: 0.0);
    // 해당 if 문은 menuOpen에 따라 CarouselSlider의 활성 여부가 갈리며, 그에 따라 완전 빌드 이전에 jump나 animated가 되는것을 막는다
    // if (state.menuOpen) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     pushPageIcon(0);
    //   });
    // }
  }

  void changeColor(bool type) {
    state = state.copyWith(colorType: type);
  }

  void tabBack(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (state.statusOpen) {
      state = state.copyWith(valueDy: 0.0, statusOpen: false, statusOpacity: 0.0);
    } else if (location == '/') {
      final controller = ref.read(homeControllerProvider.notifier);
      controller.tabBack();
    } else if (location == '/message') {
      final controller = ref.read(messageControllerProvider.notifier);
      controller.tabBack(context);
    } else {
      context.pop(context);
    }
  }

  void statusOpen(String type, var details) {
    if (type == 'start') {
      state = state.copyWith(startDy: details.globalPosition.dy, valueDy: 0.0, statusOpen: true);
    } else if (type == 'update') {
      if (details.globalPosition.dy > state.startDy) {
        state = state.copyWith(valueDy: details.globalPosition.dy - state.startDy, statusOpacity: min(state.valueDy / 300, 1.0));
      }
    } else if (type == 'end') {
      state = state.copyWith(endDy: details.globalPosition.dy);
      // 300 이상 내렷을 경우 메뉴 열기 그렇지 않다면 원위치
      if (state.endDy - state.startDy > 300) {
        state = state.copyWith(valueDy: app_height, statusOpacity: 1);
      } else {
        state = state.copyWith(valueDy: 0.0, statusOpacity: 0.0, statusOpen: false);
      }
    }
  }

  void statusClose(String type, var details) {
    if (type == 'start') {
      state = state.copyWith(startDy: details.globalPosition.dy, valueDy: app_height);
    } else if (type == 'update') {
      Offset globalPosition = details.globalPosition;
      if (state.valueDy > 1) {
        // 올라간만큼 계산
        double nowValue = state.startDy - globalPosition.dy;
        // 조금이라도 아래로 내려갈경우 nowValue가 음수가 되어 manuOpacity가 1보다 커지는 현상 방지
        if (nowValue > 0) {
          state = state.copyWith(valueDy: app_height - nowValue, statusOpacity: max(1 - (nowValue / 300), 0.0));
        }
      }
    } else if (type == 'end') {
      state = state.copyWith(endDy: details.globalPosition.dy);
      // 200 이상 올렸을 경우 메뉴 닫기
      // 닫을때는 수가 반대이므로 -200 보다 작을경우 메뉴를 닫고 그렇지 않을경우 원위치
      if (state.endDy - state.startDy > -200) {
        state = state.copyWith(valueDy: app_height, statusOpacity: 1);
      } else {
        state = state.copyWith(valueDy: 0.0, statusOpacity: 0.0, statusOpen: false);
      }
    }
  }
}

final layoutControllerProvider = StateNotifierProvider<LayoutController, LayoutState>((ref) {
  return LayoutController(ref);
});
