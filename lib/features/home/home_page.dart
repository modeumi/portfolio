import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/widgets/Home/home_icon_field.dart';
import 'package:portfolio/core/widgets/Home/home_page_view.dart';
import 'package:portfolio/features/home/home_controller.dart';
import 'package:portfolio/features/layout/layout_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

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
                    Opacity(
                      opacity: 1.0 - homeState.statusOpacity,
                      child: GestureDetector(
                        onPanStart: (details) => controller.statusOpen('start', details),
                        onPanUpdate: (details) => controller.statusOpen('update', details),
                        onPanEnd: (details) => controller.statusOpen('end', details),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: Row(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Portfolio', style: white(18, FontWeight.w500)),
                              Text(homeState.clock, style: white(18, FontWeight.w600)),
                              Spacer(),
                              Icon(Icons.signal_cellular_alt_outlined, color: color_white),
                              Container(
                                width: 50,
                                padding: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(color: pBackGrey, borderRadius: BorderRadius.circular(30)),
                                child: Center(child: Text('95', style: white(16, FontWeight.w600))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
