import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:utility/import_package.dart';

// 상태 객체 (데이터 Model) >> 여기에서는 loading 상태와 게시글 목록을 관리함
class HomeState {
  final bool loading;
  final String clock; //
  final bool power;
  final bool statusOpen;
  final bool menuOpen; //
  final double startDy; //
  final double endDy; //
  final double valueDy; //
  final double statusOpacity; //
  final double menuOpacity;
  final int pageNumber;
  final Map<String, dynamic> apps = {
    'bottomMenu': {'reminder': '리마인드', 'note': '노트', 'message': '메세지', 'apps': '앱스'}, // 하단에 띄울 앱, 이름 미출력
    'mainMenu': {'notion': 'Notion', 'github': 'GitHub', 'blog': '네이버 블로그'}, // 메인화면에 출력할 주요 앱
    'profile': {'profile': '내정보'}, // 내정보 앱
    'sns': {'kakao': '카카오톡', 'discord': 'Discord'}, // 메인에는 출력하지않으나 앱스를 클릭했을때 출력할 앱
  };
  final Map<String, dynamic> links = {
    'notion': 'https://bedecked-beetle-069.notion.site/Project-293f367dbc9e8038856dc5b65353f87f',
    'blog': 'https://blog.naver.com/modeumi-',
    'github': 'https://github.com/modeumi',
    'kakao': 'https://open.kakao.com/o/sE4tdmYh',
    'discord': 'https://discord.com/users/393283108146774018',
  };

  HomeState({
    this.loading = true,
    this.clock = '',
    this.power = true,
    this.statusOpen = false,
    this.menuOpen = false,
    this.startDy = 0.0,
    this.endDy = 0.0,
    this.valueDy = 0.0,
    this.statusOpacity = 0.0,
    this.menuOpacity = 0.0,
    this.pageNumber = 0,
  });

  HomeState copyWith({
    bool? loading,
    String? clock,
    bool? power,
    bool? statusOpen,
    bool? menuOpen,
    double? startDy,
    double? endDy,
    double? valueDy,
    double? statusOpacity,
    double? menuOpacity,
    int? pageNumber,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      power: power ?? this.power,
      clock: clock ?? this.clock,
      statusOpen: statusOpen ?? this.statusOpen,
      menuOpen: menuOpen ?? this.menuOpen,
      startDy: startDy ?? this.startDy,
      endDy: endDy ?? this.endDy,
      valueDy: valueDy ?? this.valueDy,
      statusOpacity: statusOpacity ?? this.statusOpacity,
      menuOpacity: menuOpacity ?? this.menuOpacity,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

// 메인 컨트롤러 >> 여기서 상태나 UI를 변경하는 로직을 작성함
class HomeController extends StateNotifier<HomeState> {
  final CarouselSliderController pageController = CarouselSliderController();

  HomeController() : super(HomeState());

  void setPower(bool power) {
    if (power) {
      state = state.copyWith(power: true);
    } else {
      state = state.copyWith(power: false, valueDy: 0.0, statusOpen: false, statusOpacity: 0.0);
    }
  }

  void tabIcon(BuildContext context, String title) async {
    if (title == 'apps') {
      int pageNum = state.pageNumber;
      state = state.copyWith(menuOpen: true, menuOpacity: 1, pageNumber: pageNum);
    } else if (state.apps['mainMenu'].keys.contains(title) || state.apps['sns'].keys.contains(title)) {
      final Uri url = Uri.parse(state.links[title]);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // 새 탭에서 열기
        // webOnlyWindowName: '_blank', // 웹에서 새 탭 강제
      )) {
        throw 'Could not launch $url';
      }
    } else {
      context.go('/$title');
    }
  }

  void tabBack() {
    if (state.menuOpen) {
      state = state.copyWith(menuOpen: false, menuOpacity: 0);
    } else if (state.pageNumber == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pushPageIcon(0);
      });
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

  void pushPageIcon(int index) {
    pageController.animateToPage(index);

    setPageNumber(index);
  }

  void setPageNumber(int index) {
    state = state.copyWith(pageNumber: index);
  }

  Map<String, dynamic> getAppsValue(int startIndex, int endIndex) {
    Map<String, dynamic> valuesDict = Map.fromEntries(state.apps.values.expand((m) => m.entries));
    valuesDict.remove('apps');
    List<dynamic> keysSlice = valuesDict.keys.toList().sublist(startIndex, min(valuesDict.length, endIndex));
    Map<String, dynamic> returnData = {for (var key in keysSlice) key: valuesDict[key]};
    return returnData;
  }

  Widget buildImage(String path) {
    if (state.apps['profile'].containsKey(path)) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(color: pWhite),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage('images/$path.png'), fit: BoxFit.cover),
          ),
        ),
      );
    } else {
      return SvgPicture.asset('images/$path.svg');
    }
  }
}

/// Riverpod Provider 정의
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});
