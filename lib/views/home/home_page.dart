import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/views/home/widgets/home_icon.dart';
import 'package:portfolio/views/home/widgets/home_icon_field.dart';
import 'package:portfolio/views/home/widgets/home_page_view.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with RiverpodMixin, TickerProviderStateMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final from = GoRouterState.of(context).uri.queryParameters['from'];

    if (from == 'browser') {
      layoutController.changeColor(true);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.changeColor(false);
      homeController.initHome();
      homeController.getProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: app_width,
      height: app_height,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: homeState.menuOpen
                ? Container()
                : Column(
                    children: [
                      Expanded(child: HomePageView()),
                      HomeIconField(iconData: homeState.apps['bottomMenu'], showContent: false),
                    ],
                  ),
          ),
          // menu 오픈 시 배경 위젯
          Positioned(
            bottom: 0,
            child: Blur(
              blur: homeState.menuOpacity * 20,
              blurColor: pBackGrey,
              colorOpacity: homeState.menuOpacity * 0.3,
              child: AnimatedSize(
                duration: Duration(milliseconds: 200),
                child: homeState.menuOpen ? SizedBox(height: app_height, width: app_width) : SizedBox(height: 0, width: app_width),
              ),
            ),
          ),
          // menu 오픈 시 메인위젯
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: homeState.menuOpen ? 0 : -(app_height),
            // 페이드 없이 순수 슬라이드 → 열기(아래→위)/닫기(위→아래)가 대칭으로 보이도록
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              opacity: 1,
              child: Container(
                width: app_width,
                height: app_height,
                padding: EdgeInsets.symmetric(vertical: app_width * 0.2),
                child: homeState.selectFolder == ''
                    ? Column(
                        children: [
                          for (int i = 0; i < Map.fromEntries(homeState.apps.values.expand((m) => m.entries)).values.length; i += 4)
                            HomeIconField(iconData: homeController.getAppsValue(i, i + 4), showContent: true),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          homeController.closeFolder();
                        },
                        child: Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              Flexible(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    homeController.closeFolder();
                                  },
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(color: Colors.transparent),
                                    child: Center(child: Text(homeController.returnName(homeState.selectFolder), style: white(40, FontWeight.w700))),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: color_white.withValues(alpha: 0.5)),
                                    child: LayoutBuilder(
                                      builder: (context, c) {
                                        final entries = homeState.folderData[homeState.selectFolder].entries.toList();
                                        const int minCells = 16; // 4 x 4 (여분 빈칸 확보)
                                        // 가용 높이를 4행으로 나눠 셀 높이 결정(아이콘+라벨 overflow 방지)
                                        final double rowExtent = (c.maxHeight - 10 * 3) / 4;
                                        final int count = entries.length > minCells ? entries.length : minCells;
                                        return GridView.builder(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            mainAxisExtent: rowExtent,
                                          ),
                                          itemCount: count,
                                          itemBuilder: (context, i) {
                                            if (i >= entries.length) return const SizedBox.shrink();
                                            final e = entries[i];
                                            return HomeIcon(e.key, e.value, true);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
