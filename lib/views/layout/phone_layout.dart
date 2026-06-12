import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/controllers/home_controller.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:utility/loading_indicator.dart';
import 'package:utility/textstyle.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

class PhoneLayout extends ConsumerStatefulWidget {
  final Widget child;

  const PhoneLayout(this.child, {super.key});

  @override
  ConsumerState<PhoneLayout> createState() => _PhoneLayoutState();
}

class _PhoneLayoutState extends ConsumerState<PhoneLayout> with RiverpodMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() => layoutController.setPhoneInit());
    Future.microtask(() => layoutController.setClock());

    // 로딩 페이지를 거치지 않고(/manage 등에서 새로고침 후) phone 화면으로 바로 진입하면
    // phoneBoot가 false로 남아 상단 상태바/하단 네비가 가려지므로, 부팅 상태로 보정한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final path = GoRouterState.of(context).uri.path;
      if (path != '/loading') {
        loadingController.bootPhone();
      }
    });

    // 뒤로가기를 눌렀다면 무조건 특정 페이지로 이동
    web.window.addEventListener(
      'popstate',
      (web.Event event) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/');
          }
        });
      }.toJS,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pBackGrey,
      body: layoutState.bootLoading
          ? Container(
              decoration: BoxDecoration(color: pBackBlack),
              child: LoadingIndicator(color: primary),
            )
          : Stack(
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
                            // initHome만 구독 (페이지 전환 등 다른 homeState 변경으로 폰 프레임 전체가 리빌드되지 않도록)
                            if (ref.watch(homeControllerProvider.select((s) => s.initHome)))
                              Positioned.fill(child: Image.asset('assets/images/back.jpg', fit: BoxFit.fill)),
                            // 메인 위젯
                            widget.child,
                            // 오픈되지않은 스테이터스 바
                            if (loadingState.phoneBoot)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Opacity(
                                    opacity: 1.0 - layoutState.statusOpacity,
                                    child: GestureDetector(
                                      onPanStart: (details) => layoutController.statusOpen('start', details),
                                      onPanUpdate: (details) => layoutController.statusOpen('update', details),
                                      onPanEnd: (details) => layoutController.statusOpen('end', details),
                                      child: Opacity(
                                        opacity: 1 - layoutState.statusOpacity,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(color: Colors.transparent),
                                          child: Builder(
                                            builder: (context) {
                                              final path = GoRouterState.of(context).uri.path;
                                              bool home = path == '/';
                                              Color fontColor = home
                                                  ? pWhite
                                                  : layoutState.colorType
                                                  ? pBackBlack
                                                  : pWhite;
                                              return Row(
                                                spacing: 10,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text('Portfolio', style: custom(18, FontWeight.w500, fontColor)),
                                                  Text(layoutState.clock, style: custom(18, FontWeight.w600, fontColor)),
                                                  Spacer(),
                                                  Icon(Icons.signal_cellular_alt_outlined, color: fontColor),
                                                  Container(
                                                    width: 50,
                                                    padding: EdgeInsets.symmetric(vertical: 3),
                                                    decoration: BoxDecoration(color: fontColor, borderRadius: BorderRadius.circular(30)),
                                                    // 배터리 박스 배경(fontColor)과 대비되도록: 검정 박스면 흰 글씨
                                                    child: Center(child: Text('95', style: custom(16, FontWeight.w600, fontColor == pWhite ? textColor : pWhite))),
                                                  ),
                                                ],
                                              );
                                            },
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
                                onPanStart: (details) => layoutController.statusClose('start', details),
                                onPanUpdate: (details) => layoutController.statusClose('update', details),
                                onPanEnd: (details) => layoutController.statusClose('end', details),
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
                                            Text('Portfolio', style: white(18, FontWeight.w500)),
                                            Spacer(),
                                            Icon(Icons.signal_cellular_alt_outlined, color: pWhite),
                                            Container(
                                              width: 50,
                                              padding: EdgeInsets.symmetric(vertical: 3),
                                              decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(30)),
                                              child: Center(child: Text('84', style: black(16, FontWeight.w600))),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 10,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(layoutState.clock, style: white(25, FontWeight.w800)),
                                            Text(date_to_string_MMdd('kor_date', DateTime.now()), style: white(20, FontWeight.w500)),
                                            Spacer(),
                                            // 로그인 아이콘 (실제 핸드폰 아이콘중 edit)
                                            GestureDetector(
                                              onTap: () => context.push('/login'),
                                              child: Icon(Icons.edit, color: color_white),
                                            ),
                                            GestureDetector(
                                              onTap: () => layoutController.setPower(false),
                                              child: Icon(Icons.power_settings_new, color: color_white),
                                            ),
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
                            if (loadingState.phoneBoot)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Builder(
                                    builder: (context) {
                                      final path = GoRouterState.of(context).uri.path;
                                      bool home = path == '/';
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(),
                                          for (var i in ['menu', 'home', 'back'])
                                            IconButton(
                                              onPressed: () {
                                                if (i == 'home') {
                                                  // 메뉴/폴더 닫고 홈 메인(탭1)으로 이동
                                                  final bool onHome = GoRouterState.of(context).uri.path == '/';
                                                  layoutController.tapHome();
                                                  homeController.goMain();
                                                  layoutController.changeColor(false);
                                                  if (!onHome) context.go('/');
                                                  // 이미 홈이면 캐러셀을 탭1로 애니메이션
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    homeController.pushPageIcon(0);
                                                  });
                                                } else if (i == 'back') {
                                                  layoutController.tabBack(context);
                                                }
                                              },
                                              icon: SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: SvgPicture.asset(
                                                  'assets/images/$i.svg',
                                                  colorFilter: ColorFilter.mode(
                                                    home
                                                        ? pWhite
                                                        : layoutState.colorType
                                                        ? pBackBlack
                                                        : pWhite,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (layoutState.actionLoading) Center(child: LoadingAnimationWidget.threeArchedCircle(color: secondary, size: 40)),
                            if (!layoutState.power)
                              GestureDetector(
                                onDoubleTap: () => layoutController.setPower(true),
                                child: Container(
                                  width: app_width,
                                  height: app_height,
                                  decoration: BoxDecoration(color: color_black),
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
    );
  }
}
