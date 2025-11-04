import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/controllers/layout_controller.dart';
import 'package:portfolio/controllers/loading_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:utility/loading_indicator.dart';
import 'package:utility/textstyle.dart';

class PhoneLayout extends ConsumerStatefulWidget {
  final Widget child;

  const PhoneLayout(this.child, {super.key});

  @override
  ConsumerState<PhoneLayout> createState() => _PhoneLayoutState();
}

class _PhoneLayoutState extends ConsumerState<PhoneLayout> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() => ref.read(layoutControllerProvider.notifier).setPhoneInit());
    Future.microtask(() => ref.read(layoutControllerProvider.notifier).setClock());
  }

  @override
  Widget build(BuildContext context) {
    final layoutState = ref.watch(layoutControllerProvider);
    final controller = ref.read(layoutControllerProvider.notifier);
    final lodingState = ref.watch(loadingControllerProvider);
    return Scaffold(
      backgroundColor: pBackGrey,
      body: layoutState.bootLoading
          ? LoadingIndicator(color: primary)
          : layoutState.power
          ? Stack(
              children: [
                if (layoutState.svgData != null)
                  Center(
                    child: SizedBox(
                      width: app_width,
                      height: app_height,
                      child: SvgPicture.string(layoutState.svgData ?? '', fit: BoxFit.fill),
                    ),
                  ),
                Center(
                  child: Container(
                    width: app_width,
                    height: app_height,
                    padding: const EdgeInsets.fromLTRB(6, 5, 10, 8),
                    child: AnimatedContainer(
                      width: app_width,
                      height: app_height,
                      duration: Duration(seconds: 1),
                      decoration: BoxDecoration(color: color_black, borderRadius: BorderRadius.circular(25)),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(25),
                        child: Stack(
                          children: [
                            Positioned.fill(child: Image.asset('assets/images/back.jpg', fit: BoxFit.fill)),
                            // 메인 위젯
                            widget.child,
                            // 오픈되지않은 스테이터스 바
                            if (lodingState.phoneBoot)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Opacity(
                                    opacity: 1.0 - layoutState.statusOpacity,
                                    child: GestureDetector(
                                      onPanStart: (details) => controller.statusOpen('start', details),
                                      onPanUpdate: (details) => controller.statusOpen('update', details),
                                      onPanEnd: (details) => controller.statusOpen('end', details),
                                      child: Opacity(
                                        opacity: 1 - layoutState.statusOpacity,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(color: Colors.transparent),
                                          child: Row(
                                            spacing: 10,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text('Portfolio', style: custom(18, FontWeight.w500, layoutState.colorType ? pBackBlack : pWhite)),
                                              Text(
                                                layoutState.clock,
                                                style: custom(18, FontWeight.w600, layoutState.colorType ? pBackBlack : pWhite),
                                              ),
                                              Spacer(),
                                              Icon(Icons.signal_cellular_alt_outlined, color: layoutState.colorType ? pBackBlack : pWhite),
                                              Container(
                                                width: 50,
                                                padding: EdgeInsets.symmetric(vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: layoutState.colorType ? pBackBlack : pWhite,
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                child: Center(
                                                  child: Text('95', style: custom(16, FontWeight.w600, layoutState.colorType ? pWhite : pBackBlack)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            // 오픈된 스테이터스 바 : 배경
                            if (layoutState.statusOpen)
                              GestureDetector(
                                onPanStart: (details) => controller.statusClose('start', details),
                                onPanUpdate: (details) => controller.statusClose('update', details),
                                onPanEnd: (details) => controller.statusClose('end', details),
                                child: Blur(
                                  blur: layoutState.statusOpacity * 20,
                                  blurColor: color_grey,
                                  colorOpacity: layoutState.statusOpacity * 0.3,
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    constraints: BoxConstraints(minHeight: 0),
                                    padding: EdgeInsets.only(bottom: 20),
                                  ),
                                ),
                              ),
                            // 오픈된 스테이터스 바 : 내용
                            if (layoutState.statusOpen)
                              Positioned.fill(
                                child: Opacity(
                                  opacity: layoutState.statusOpacity,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                            Text(layoutState.clock, style: black(25, FontWeight.w800)),
                                            Text(date_to_string_MMdd('kor_date', DateTime.now()), style: black(20, FontWeight.w500)),
                                            Spacer(),
                                            // 로그인 아이콘 (실제 핸드폰 아이콘중 edit)
                                            GestureDetector(onTap: () => context.push('/login'), child: Icon(Icons.edit)),
                                            GestureDetector(onTap: () => controller.setPower(false), child: Icon(Icons.power_settings_new)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            // 상단 카메라 부분
                            Positioned(
                              top: 10,
                              left: 0,
                              right: 0,
                              child: Container(
                                width: 25,
                                height: 25,
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(color: pBackBlack, shape: BoxShape.circle),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(color: pBackGrey, shape: BoxShape.circle),
                                ),
                              ),
                            ),
                            // 하단 네비게이션 바
                            if (lodingState.phoneBoot)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                              controller.tabBack(context);
                                            }
                                          },
                                          icon: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: SvgPicture.asset('images/$i.svg', color: layoutState.colorType ? pBackBlack : pWhite),
                                          ),
                                        ),
                                      SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                            if (layoutState.actionLoading) Center(child: LoadingAnimationWidget.stretchedDots(color: primary, size: 30)),
                          ],
                        ),
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
