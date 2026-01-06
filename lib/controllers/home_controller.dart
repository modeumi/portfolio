import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:utility/import_package.dart';

// 상태 객체 (데이터 Model) >> 여기에서는 loading 상태와 게시글 목록을 관리함
class HomeState {
  final bool loading;
  final bool menuOpen;
  final bool initHome;

  final int pageNumber;

  final double menuOpacity;

  final String selectFolder;

  final Map<String, dynamic> apps = {
    'bottomMenu': {'note': '노트', 'message': '채팅', 'calendar': '캘린더', 'apps': '앱스'}, // 하단에 띄울 앱, 이름 미출력
    'mainMenu': {'notion': 'Notion', 'github': 'GitHub', 'blog': '네이버 블로그'}, // 메인화면에 출력할 주요 앱
    'profile': {'profile': '내정보'}, // 내정보 앱
    'etc': {'kakao': '카카오톡', 'discord': 'Discord', 'folder_1': '프로젝트'}, // 메인에는 출력하지않으나 앱스를 클릭했을때 출력할 앱
  };

  final Map<String, dynamic> folderData = {
    'folder_1': {'ERP': '모빌리티 ERP', 'projectS': '프로젝트 S', 'sfac': '스팩스페이스', 'todayEat': '오늘뭐먹지?'},
  };
  final Map<String, dynamic> links = {
    'notion': 'https://bedecked-beetle-069.notion.site/Project-293f367dbc9e8038856dc5b65353f87f',
    'blog': 'https://blog.naver.com/modeumi-',
    'github': 'https://github.com/modeumi',
    'kakao': 'https://open.kakao.com/o/sE4tdmYh',
    'discord': 'https://discord.com/users/393283108146774018',
    'ERP': '',
    'projectS': '',
    'sfac': '',
    'todayEat': '',
  };

  HomeState({this.loading = true, this.initHome = false, this.menuOpen = false, this.menuOpacity = 0.0, this.pageNumber = 0, this.selectFolder = ''});

  HomeState copyWith({bool? loading, bool? menuOpen, bool? initHome, double? menuOpacity, int? pageNumber, String? selectFolder}) {
    return HomeState(
      loading: loading ?? this.loading,
      menuOpen: menuOpen ?? this.menuOpen,
      menuOpacity: menuOpacity ?? this.menuOpacity,
      pageNumber: pageNumber ?? this.pageNumber,
      initHome: initHome ?? this.initHome,
      selectFolder: selectFolder ?? this.selectFolder,
    );
  }
}

// 메인 컨트롤러 >> 여기서 상태나 UI를 변경하는 로직을 작성함
class HomeController extends StateNotifier<HomeState> {
  final CarouselSliderController pageController = CarouselSliderController();

  HomeController() : super(HomeState());

  void initHome() {
    state = state.copyWith(initHome: true);
  }

  void tabIcon(BuildContext context, String title) async {
    if (title == 'apps') {
      int pageNum = state.pageNumber;
      state = state.copyWith(menuOpen: true, menuOpacity: 1, pageNumber: pageNum);
    } else if (state.folderData.containsKey(title)) {
      selectFolder(title);
    } else if (state.links.containsKey(title)) {
      final Uri url = Uri.parse(state.links[title]);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // 새 탭에서 열기
        // webOnlyWindowName: '_blank', // 웹에서 새 탭 강제
      )) {
        throw 'Could not launch $url';
      }
    } else {
      context.push('/$title');
    }
  }

  void tabBack() {
    if (state.menuOpen) {
      if (state.selectFolder != '') {
        selectFolder('');
      } else {
        state = state.copyWith(menuOpen: false, menuOpacity: 0);
      }
    } else if (state.pageNumber == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pushPageIcon(0);
      });
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
    } else if (state.folderData.containsKey(path)) {
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: pWhite.withOpacity(0.5)),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
          children: [
            for (var i in state.folderData[path].entries)
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(5), child: SvgPicture.asset('images/${i.key}.svg')),
              ),
          ],
        ),
      );
    } else {
      return SvgPicture.asset('images/$path.svg');
    }
  }

  void selectFolder(String key) {
    state = state.copyWith(selectFolder: key);
  }

  String returnName(String key) {
    String name = '';
    for (var i in state.apps.entries) {
      for (var app in i.value.entries) {
        if (app.key == key) {
          name = app.value;
        }
      }
    }
    return name;
  }
}

/// Riverpod Provider 정의
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});
