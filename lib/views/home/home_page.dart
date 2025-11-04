import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/views/home/widgets/home_icon_field.dart';
import 'package:portfolio/views/home/widgets/home_page_view.dart';
import 'package:portfolio/controllers/home_controller.dart';
import 'package:portfolio/controllers/layout_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(layoutControllerProvider.notifier).changeColor(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    return Container(
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
          if (homeState.menuOpen)
            Blur(
              blur: homeState.menuOpacity * 20,
              blurColor: pBackGrey,
              colorOpacity: homeState.menuOpacity * 0.3,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: double.infinity,
                height: homeState.menuOpen ? double.infinity : 0,
              ),
            ),
          // menu 오픈 시 메인위젯
          if (homeState.menuOpen)
            Positioned.fill(
              child: SizedBox(
                child: Column(
                  children: [
                    for (int i = 0; i < Map.fromEntries(homeState.apps.values.expand((m) => m.entries)).values.length; i += 4)
                      HomeIconField(iconData: controller.getAppsValue(i, i + 4), showContent: true),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
