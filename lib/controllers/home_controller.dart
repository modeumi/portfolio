import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/controllers/manage_controller.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:utility/import_package.dart';

// 상태 객체 (데이터 Model) >> 여기에서는 loading 상태와 게시글 목록을 관리함
class HomeState {
  final bool loading;
  final bool menuOpen;
  final bool initHome;

  final int pageNumber;

  final double menuOpacity;

  final String selectFolder;

  // 폴더를 앱스 드로어에서 열었는지(true) 메인 화면에서 열었는지(false)
  final bool folderFromMenu;

  final Map<String, dynamic> apps = {
    'bottomMenu': {'note': '노트', 'message': '채팅', 'calendar': '캘린더', 'apps': '앱스'}, // 하단에 띄울 앱, 이름 미출력
    'mainMenu': {'folder_1': '프로젝트', 'empty': '', 'notion': 'Notion', 'github': 'GitHub'}, // 메인: notion, github, 빈칸, 프로젝트 폴더
    'profile': {'profile': '내정보'}, // 내정보 앱
    'etc': {'blog': '네이버 블로그', 'kakao': '카카오톡', 'discord': 'Discord'}, // 메인에는 출력하지않으나 앱스를 클릭했을때 출력할 앱
  };

  // folder_1(프로젝트 폴더) 내용: { projectId: projectName } — manage_controller projectList에서 파생
  final Map<String, dynamic> folderData;

  final Map<String, dynamic> links = {
    'notion': 'https://bedecked-beetle-069.notion.site/Project-293f367dbc9e8038856dc5b65353f87f',
    'blog': 'https://blog.naver.com/modeumi-',
    'github': 'https://github.com/modeumi',
    'kakao': 'https://open.kakao.com/o/sE4tdmYh',
    'discord': 'https://discord.com/users/393283108146774018',
  };

  HomeState({
    this.loading = true,
    this.initHome = false,
    this.menuOpen = false,
    this.menuOpacity = 0.0,
    this.pageNumber = 0,
    this.selectFolder = '',
    this.folderFromMenu = false,
    Map<String, dynamic>? folderData,
  }) : folderData = folderData ?? const {'folder_1': <String, dynamic>{}};

  HomeState copyWith({
    bool? loading,
    bool? menuOpen,
    bool? initHome,
    double? menuOpacity,
    int? pageNumber,
    String? selectFolder,
    bool? folderFromMenu,
    Map<String, dynamic>? folderData,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      menuOpen: menuOpen ?? this.menuOpen,
      menuOpacity: menuOpacity ?? this.menuOpacity,
      pageNumber: pageNumber ?? this.pageNumber,
      initHome: initHome ?? this.initHome,
      selectFolder: selectFolder ?? this.selectFolder,
      folderFromMenu: folderFromMenu ?? this.folderFromMenu,
      folderData: folderData ?? this.folderData,
    );
  }
}

// 메인 컨트롤러 >> 여기서 상태나 UI를 변경하는 로직을 작성함
class HomeController extends StateNotifier<HomeState> {
  final Ref ref;
  final CarouselSliderController pageController = CarouselSliderController();

  HomeController(this.ref) : super(HomeState());

  void initHome() {
    state = state.copyWith(initHome: true);
  }

  // manage_controller(단일 소스)에서 프로젝트를 불러와 folder_1(프로젝트 폴더) 내용으로 파생
  Future<void> getProjects() async {
    await ref.read(manageControllerProvider.notifier).getProjects();
    final list = ref.read(manageControllerProvider).projectList;
    final Map<String, dynamic> folder = {for (final p in list) (p.id ?? ''): (p.name ?? '')};
    state = state.copyWith(folderData: {'folder_1': folder});
  }

  ProjectModel? findProject(String id) {
    for (final p in ref.read(manageControllerProvider).projectList) {
      if (p.id == id) return p;
    }
    return null;
  }

  // 프로젝트 아이콘(네트워크 URL / asset)을 영역에 꽉 차게 렌더
  Widget projectIconFill(String? icon) {
    if (icon == null || icon.isEmpty) {
      return Container(
        color: pWhite,
        child: Icon(Icons.folder_rounded, color: pBackGrey2),
      );
    }
    if (icon.startsWith('http')) return Image.network(icon, fit: BoxFit.cover);
    if (icon.endsWith('.svg')) return SvgPicture.asset(icon, fit: BoxFit.cover);
    return Image.asset(icon, fit: BoxFit.cover);
  }

  void tabIcon(BuildContext context, String title) async {
    if (title == 'apps') {
      int pageNum = state.pageNumber;
      state = state.copyWith(menuOpen: true, menuOpacity: 1, pageNumber: pageNum);
    } else if (state.folderData.containsKey(title)) {
      // 폴더를 어디서 열었는지 기록(드로어=true / 메인=false) 후, 메뉴 오버레이를 열어 폴더 표시
      final bool fromMenu = state.menuOpen;
      state = state.copyWith(menuOpen: true, menuOpacity: 1, folderFromMenu: fromMenu, selectFolder: title);
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
      // 프로젝트 아이콘 → 상세 페이지로 이동
      final project = findProject(title);
      if (project != null) {
        ref.read(manageControllerProvider.notifier).setProject(project);
        context.push('/project_detail');
      } else {
        context.push('/$title');
      }
    }
  }

  // 홈 버튼: 앱스 메뉴/폴더를 닫고 메인(탭1)으로 복귀
  void goMain() {
    state = state.copyWith(menuOpen: false, menuOpacity: 0, selectFolder: '', pageNumber: 0);
  }

  // 폴더 닫기: 드로어에서 열었으면 폴더만 닫고, 메인에서 열었으면 메뉴까지 닫아 직전 home으로
  void closeFolder() {
    if (state.folderFromMenu) {
      selectFolder('');
    } else {
      state = state.copyWith(menuOpen: false, menuOpacity: 0, selectFolder: '');
    }
  }

  void tabBack() {
    if (state.menuOpen) {
      if (state.selectFolder != '') {
        closeFolder();
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
    try {
      pageController.animateToPage(index);
    } catch (_) {
      // 캐러셀이 아직 마운트되지 않은 경우(메뉴 열림/다른 라우트)는 무시
    }
    setPageNumber(index);
  }

  void setPageNumber(int index) {
    state = state.copyWith(pageNumber: index);
  }

  Map<String, dynamic> getAppsValue(int startIndex, int endIndex) {
    Map<String, dynamic> valuesDict = Map.fromEntries(state.apps.values.expand((m) => m.entries));
    valuesDict.remove('apps');
    valuesDict.remove('empty');
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
            image: DecorationImage(image: AssetImage('assets/images/$path.png'), fit: BoxFit.cover),
          ),
        ),
      );
    } else if (state.folderData.containsKey(path)) {
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: pWhite.withValues(alpha: 0.5)),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
          children: [
            for (var i in state.folderData[path].entries)
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(5), child: projectIconFill(findProject(i.key)?.icon)),
              ),
          ],
        ),
      );
    } else {
      // 프로젝트 아이콘(네트워크) 또는 기존 asset
      final project = findProject(path);
      if (project != null) return projectIconFill(project.icon);
      return SvgPicture.asset('assets/images/$path.svg');
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
  return HomeController(ref);
});
