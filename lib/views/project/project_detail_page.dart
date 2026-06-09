import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로젝트 게시물(상세) 페이지 - 아이템 클릭 시 진입
// TODO: content 의 특수 태그(이미지/줄바꿈/색상/크기/굵기) 파싱하여 본문 렌더링
class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({super.key});

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> with RiverpodMixin {
  @override
  Widget build(BuildContext context) {
    final project = manageState.project;
    return Container(
      decoration: BoxDecoration(color: pWhite),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(Icons.arrow_back_ios_new, size: 28, color: color_black),
          ),
          SizedBox(height: 20),
          Text(project.name ?? '', style: black(28, FontWeight.w800)),
        ],
      ),
    );
  }
}
