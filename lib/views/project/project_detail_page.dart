import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:portfolio/views/project/widgets/project_content.dart';
import 'package:portfolio/views/project/widgets/project_icon.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로젝트 게시물(소개) 페이지 - 프로젝트 탭에서 아이템 선택 시 진입
// 선택된 ProjectModel 의 icon / name / content / background 를 배치한다.
class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({super.key});

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> with RiverpodMixin {
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

    // 배경: firebase storage 이미지(http) / #hex 색상 / 기본 흰색
    final bool onImage = bg != null && bg.startsWith('http');
    BoxDecoration decoration;
    if (onImage) {
      decoration = BoxDecoration(image: DecorationImage(image: NetworkImage(bg), fit: BoxFit.cover));
    } else if (bg != null && bg.startsWith('#')) {
      decoration = BoxDecoration(color: _hexColor(bg) ?? pWhite);
    } else {
      decoration = BoxDecoration(color: pWhite);
    }

    // 이미지 배경 위에서는 헤더 글씨를 흰색 + 그림자로
    final TextStyle titleStyle = onImage
        ? custom(34, FontWeight.w800, Colors.white).copyWith(shadows: [Shadow(color: Colors.black54, blurRadius: 8)])
        : black(34, FontWeight.w800);
    final Color iconBtnColor = onImage ? Colors.white : color_black;

    return Container(
      width: double.infinity,
      decoration: decoration,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 뒤로가기
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.arrow_back_ios_new, size: 28, color: iconBtnColor),
              ),
            ),

            // 최상단: 큼직한 아이콘 + 타이틀 (소개 진입 인지)
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: pWhite,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(offset: const Offset(0, 6), color: pBackGrey2, blurRadius: 14)],
                    ),
                    child: Center(child: projectIcon(project.icon, 74)),
                  ),
                  const SizedBox(height: 18),
                  Text(project.name ?? '', style: titleStyle, textAlign: TextAlign.center),
                ],
              ),
            ),

            // 일정한 여백 후 content 영역
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: pWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(offset: const Offset(0, 3), color: pBackGrey2, blurRadius: 8)],
                ),
                child: (project.content == null || project.content!.isEmpty)
                    ? Text('등록된 소개 내용이 없습니다', style: custom(16, FontWeight.w400, font_grey))
                    : ProjectContent(project.content!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
