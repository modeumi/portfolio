// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/controllers/home_controller.dart';
import 'package:portfolio/controllers/message_controller.dart';
import 'package:utility/format.dart';

class LayoutState {
  final bool admin;
  final bool bootLoading;
  final bool actionLoading;
  final bool power;
  final bool statusOpen;
  final bool colorType;
  final bool dialogOpen;

  final String? svgData;
  final String clock;

  final double startDy;
  final double endDy;
  final double valueDy;
  final double statusOpacity;

  final OverlayEntry? overlay;

  const LayoutState({
    this.admin = false,
    this.bootLoading = false,
    this.actionLoading = false,
    this.power = true,
    this.statusOpen = false,
    this.colorType = false,
    this.dialogOpen = false,

    this.svgData,
    this.clock = '',

    this.startDy = 0.0,
    this.endDy = 0.0,
    this.valueDy = 0.0,
    this.statusOpacity = 0.0,

    this.overlay,
  });

  LayoutState copyWith({
    bool? admin,
    bool? bootLoading,
    bool? actionLoading,
    bool? power,
    bool? statusOpen,
    bool? colorType,
    bool? dialogOpen,

    String? svgData,
    String? clock,

    double? startDy,
    double? endDy,
    double? valueDy,
    double? statusOpacity,

    OverlayEntry? overlay,
  }) {
    return LayoutState(
      admin: admin ?? this.admin,
      bootLoading: bootLoading ?? this.bootLoading,
      actionLoading: actionLoading ?? this.actionLoading,
      power: power ?? this.power,
      svgData: svgData ?? this.svgData,
      dialogOpen: dialogOpen ?? this.dialogOpen,
      colorType: colorType ?? this.colorType,
      clock: clock ?? this.clock,
      statusOpen: statusOpen ?? this.statusOpen,
      startDy: startDy ?? this.startDy,
      endDy: endDy ?? this.endDy,
      valueDy: valueDy ?? this.valueDy,
      statusOpacity: statusOpacity ?? this.statusOpacity,
      overlay: overlay ?? this.overlay,
    );
  }
}

class LayoutController extends StateNotifier<LayoutState> {
  final Ref ref;
  LayoutController(this.ref) : super(LayoutState());

  final auth = FirebaseAuth.instance;

  Future<void> setPhoneInit() async {
    await loadSvg('assets/images/phone.svg');
  }

  void setAdmin() {
    final admin = auth.currentUser;
    bool result = admin != null;
    state = state.copyWith(admin: result);
  }

  Future<void> loadSvg(String assetPath) async {
    try {
      // SVG 문자열 읽기
      final svgString = await rootBundle.loadString(assetPath);
      // 로드 완료 시 bootLoading false
      state = state.copyWith(bootLoading: false, svgData: svgString);
    } catch (e) {
      // 실패 시에도 bootLoading false로 바꾸고 로그 출력
      state = state.copyWith(bootLoading: false);
      print("SVG 로드 실패: $e");
    }
  }

  void setClock() async {
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      final now = DateTime.now();
      final formattedTime = time_to_string('hm', now);
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

  Future<void> withLoading(Future<void> Function() task) async {
    state = state.copyWith(actionLoading: true);
    try {
      await task();
    } catch (e, y) {
      print("에러 발생: $e \n\n$y");
    } finally {
      state = state.copyWith(actionLoading: false);
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

  void backAndChangeColor(BuildContext context, bool type) {
    changeColor(type);
    context.pop();
  }

  void tabBack(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (state.statusOpen) {
      state = state.copyWith(valueDy: 0.0, statusOpen: false, statusOpacity: 0.0);
    } else if (location == '/') {
      final controller = ref.read(homeControllerProvider.notifier);
      controller.tabBack();
    } else if (['/message', '/calendar'].contains(location)) {
      if (location == '/message') {
        ref.invalidate(messageControllerProvider);
      } else if (location == '/calendar') {
        // ref.invalidate(calendarControllerProvider);
        // 이번달 데이터만 load 하는 코드추가
      }
      backAndChangeColor(context, false);
    } else {
      context.pop();
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

  void changeDialogState(bool type) {
    state = state.copyWith(dialogOpen: type);
  }
}

final layoutControllerProvider = StateNotifierProvider<LayoutController, LayoutState>((ref) {
  return LayoutController(ref);
});
