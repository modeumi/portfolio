import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/widgets/Home/home_icon_field.dart';
import 'package:portfolio/core/widgets/Home/home_page_view.dart';
import 'package:portfolio/features/home/home_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/loading_indicator.dart';
import 'package:utility/textstyle.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeControllerProvider.notifier).setClock());
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    return Container(
      width: app_width,
      height: app_height,
      decoration: BoxDecoration(color: color_white),
      child: homeState.clock == ''
          ? Column(
              spacing: 25,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [LoadingIndicator(color: primary)],
            )
          : homeState.power == true
          ? Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('images/back.jpg'), fit: BoxFit.fill),
                    color: color_black,
                  ),
                  child: homeState.menuOpen
                      ? Container()
                      : Column(
                          children: [
                            Opacity(
                              opacity: 1.0 - homeState.statusOpacity,
                              child: GestureDetector(
                                onPanStart: (details) => controller.statusOpen('start', details),
                                onPanUpdate: (details) => controller.statusOpen('update', details),
                                onPanEnd: (details) => controller.statusOpen('end', details),
                                child: Opacity(
                                  opacity: 1 - homeState.statusOpacity,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                            ),
                            HomePageView(),
                            HomeIconField(iconData: homeState.apps['bottomMenu'], showContent: false),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(),
                                  for (var i in ['menu', 'home', 'back'])
                                    IconButton(
                                      onPressed: () {
                                        if (i == 'home') {
                                          controller.tapHome();
                                        } else if (i == 'back') {
                                          controller.tabBack();
                                        }
                                      },
                                      icon: SizedBox(width: 30, height: 30, child: SvgPicture.asset('images/$i.svg')),
                                    ),
                                  SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                // menu 오픈 시 배경 위젯
                if (homeState.menuOpen)
                  Blur(
                    blur: homeState.menuOpacity * 15,
                    blurColor: color_grey,
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
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(),
                                for (var i in ['menu', 'home', 'back'])
                                  IconButton(
                                    onPressed: () {
                                      if (i == 'home') {
                                        controller.tapHome();
                                      } else if (i == 'back') {
                                        controller.tabBack();
                                      }
                                    },
                                    icon: SizedBox(width: 30, height: 30, child: SvgPicture.asset('images/$i.svg')),
                                  ),
                                SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // status 오픈할 시 배경 위젯
                if (homeState.statusOpen)
                  GestureDetector(
                    onPanStart: (details) => controller.menuClose('start', details),
                    onPanUpdate: (details) => controller.menuClose('update', details),
                    onPanEnd: (details) => controller.menuClose('end', details),
                    child: Blur(
                      blur: homeState.statusOpacity * 20,
                      blurColor: color_grey,
                      colorOpacity: homeState.statusOpacity * 0.3,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        constraints: BoxConstraints(minHeight: 0),
                        padding: EdgeInsets.only(bottom: 20),
                      ),
                    ),
                  ),
                // status 오픈할 시 내부 객체 위젯
                if (homeState.statusOpen)
                  Positioned.fill(
                    child: Opacity(
                      opacity: homeState.statusOpacity,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                        child: Column(
                          spacing: 15,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                Text('Portfolio', style: black(18, FontWeight.w500)),
                                Spacer(),
                                Icon(Icons.signal_cellular_alt_outlined),
                                Container(
                                  width: 50,
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  decoration: BoxDecoration(color: pBackGrey, borderRadius: BorderRadius.circular(30)),
                                  child: Center(child: Text('84', style: white(16, FontWeight.w600))),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(homeState.clock, style: black(25, FontWeight.w800)),
                                Text(date_to_string_MMdd('kor_date', DateTime.now()), style: black(20, FontWeight.w500)),
                                Spacer(),
                                // 로그인 아이콘 (실제 핸드폰 아이콘중 edit)
                                GestureDetector(onTap: () => context.go('/login'), child: Icon(Icons.edit)),
                                GestureDetector(onTap: () => controller.setPower(false), child: Icon(Icons.power_settings_new)),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(),
                                for (var i in ['menu', 'home', 'back'])
                                  IconButton(
                                    onPressed: () {
                                      if (i == 'home') {
                                        controller.tapHome();
                                      } else if (i == 'back') {
                                        controller.tabBack();
                                      }
                                    },
                                    icon: SizedBox(width: 30, height: 30, child: SvgPicture.asset('images/$i.svg')),
                                  ),
                                SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : GestureDetector(
              onDoubleTap: () => controller.setPower(true),
              child: Container(
                width: app_width,
                height: app_height,
                decoration: BoxDecoration(color: color_black),
              ),
            ),
    );
  }
}
