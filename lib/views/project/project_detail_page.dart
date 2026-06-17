import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/empty_state.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:portfolio/views/project/widgets/project_content.dart';
import 'package:portfolio/views/project/widgets/project_icon.dart';
import 'package:utility/textstyle.dart';

// 프로젝트 소개 페이지 - 포트폴리오 쇼케이스 느낌으로 꾸민 상세 화면
// 히어로 헤더(아이콘 + 타이틀 + 배경) 위로 본문 시트가 떠오르는 구성
class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({super.key});

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> with RiverpodMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 휴대폰 안쪽 표시: 흰 본문에 맞춰 상태바/네비 아이콘을 어둡게
      layoutController.changeColor(true);
    });
  }

  // #RRGGBB / #AARRGGBB 색상 파싱
  Color? _hexColor(String value) {
    String v = value.replaceAll('#', '').trim();
    if (v.length == 6) v = 'ff$v';
    final n = int.tryParse(v, radix: 16);
    return n == null ? null : Color(n);
  }

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = manageState.project;
    final String? bg = project.background;
    final bool onImage = bg != null && bg.startsWith('http');
    final Color? bgColor = (bg != null && bg.startsWith('#')) ? _hexColor(bg) : null;
    final bool hasContent = project.content != null && project.content!.isNotEmpty;

    return Padding(
      // 상단 상태바 / 하단 네비 영역을 제외한 영역에만 내용 배치 (safe area)
      padding: EdgeInsets.only(top: statusBarHeight, bottom: navBarHeight),
      child: Container(
      width: double.infinity,
      decoration: BoxDecoration(color: pWhite),
      child: Stack(
        children: [
          // 이미지 배경(있을 때): 전체를 깔고 가독성용 스크림
          if (onImage) ...[
            Positioned.fill(
              child: Image.network(bg, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0.12)],
                  ),
                ),
              ),
            ),
          ],

          // 본문 (부드러운 등장 애니메이션)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(offset: Offset(0, (1 - t) * 20), child: child),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _hero(project, onImage: onImage, bgColor: bgColor),
                  // 본문 시트: 히어로 위로 살짝 겹쳐 떠오르는 느낌
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Container(
                      decoration: BoxDecoration(
                        color: pWhite,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [BoxShadow(offset: const Offset(0, -6), blurRadius: 18, color: Colors.black.withValues(alpha: 0.06))],
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 32, 22, 40),
                      child: hasContent
                          ? ProjectContent(project.content!)
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 50),
                              child: EmptyState(icon: Icons.description_outlined, message: '등록된 소개 내용이 없습니다'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // 히어로 헤더: 아이콘 + 타이틀 + 액센트 디바이더
  Widget _hero(ProjectModel project, {required bool onImage, Color? bgColor}) {
    final TextStyle titleStyle = onImage
        ? custom(33, FontWeight.w800, Colors.white).copyWith(shadows: [Shadow(color: Colors.black54, blurRadius: 10)])
        : custom(33, FontWeight.w800, textColor);

    // 헤더 배경: 이미지면 투명(아래 깔린 이미지 사용), 색이면 그 색, 없으면 부드러운 그라데이션
    BoxDecoration deco;
    if (onImage) {
      deco = const BoxDecoration();
    } else if (bgColor != null) {
      deco = BoxDecoration(color: bgColor);
    } else {
      deco = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backSurface, pMainColor.withValues(alpha: 0.35), pWhite],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: deco,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 58),
      child: Column(
        children: [
          // 아이콘 카드 (은은한 컬러 그림자)
          Container(
            width: 116,
            height: 116,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: pWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                  color: (onImage ? Colors.black : secondary).withValues(alpha: onImage ? 0.40 : 0.28),
                ),
              ],
            ),
            child: Center(child: projectIcon(project.icon, 76)),
          ),
          const SizedBox(height: 20),
          Text(project.name ?? '', style: titleStyle, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          // 액센트 디바이더
          Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: onImage ? Colors.white : accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
