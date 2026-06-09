import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로젝트 수정/작성 페이지 - 연필(edit) 아이콘 클릭 시 진입
// TODO: name / icon(firebase storage) / content 편집 폼 구현
class ProjectWritePage extends ConsumerStatefulWidget {
  const ProjectWritePage({super.key});

  @override
  ConsumerState<ProjectWritePage> createState() => _ProjectWritePageState();
}

class _ProjectWritePageState extends ConsumerState<ProjectWritePage> with RiverpodMixin {
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
          Text('${project.name ?? ''} 수정', style: black(28, FontWeight.w800)),
        ],
      ),
    );
  }
}
