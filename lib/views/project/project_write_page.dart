import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/views/project/widgets/project_icon.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로젝트 추가/수정 페이지
// project_detail 과 비슷한 양식: 아이콘 등록 필드 + 제목 필드 + 내용 작성 필드
class ProjectWritePage extends ConsumerStatefulWidget {
  const ProjectWritePage({super.key});

  @override
  ConsumerState<ProjectWritePage> createState() => _ProjectWritePageState();
}

class _ProjectWritePageState extends ConsumerState<ProjectWritePage> with RiverpodMixin {
  final TextEditingController title = TextEditingController();
  final TextEditingController content = TextEditingController();
  bool iconLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      title.text = manageState.project.name ?? '';
      content.text = manageState.project.content ?? '';
    });
  }

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    super.dispose();
  }

  Future<void> pickIcon() async {
    setState(() => iconLoading = true);
    await manageController.pickProjectIcon();
    if (mounted) setState(() => iconLoading = false);
  }

  Future<void> save() async {
    manageController.changeProjectField('name', title.text);
    manageController.changeProjectField('content', content.text);
    await manageController.saveProject();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final String? icon = manageState.project.icon;
    final bool isNew = manageState.project.id == null || manageState.project.id!.isEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: pWhite),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 뒤로가기 + 저장
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back_ios_new, size: 28, color: color_black),
                  ),
                  GestureDetector(
                    onTap: save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(20)),
                      child: Text(isNew ? '추가' : '저장', style: white(18, FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            // 아이콘 등록 필드
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: iconLoading ? null : pickIcon,
                child: Container(
                  width: 110,
                  height: 110,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: pWhite,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: color_grey, width: 1),
                    boxShadow: [BoxShadow(offset: const Offset(0, 6), color: pBackGrey2, blurRadius: 14)],
                  ),
                  child: Center(
                    child: iconLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : (icon == null || icon.isEmpty)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 34, color: color_grey),
                              const SizedBox(height: 6),
                              Text('아이콘', style: custom(13, FontWeight.w500, font_grey)),
                            ],
                          )
                        : projectIcon(icon, 74),
                  ),
                ),
              ),
            ),

            // 제목 필드
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: back_grey_2, borderRadius: BorderRadius.circular(14)),
                child: CustomTextField(
                  controller: title,
                  hint: '프로젝트 이름',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  hintColor: font_grey,
                  maxLine: 1,
                  action: () {
                    manageController.changeProjectField('name', title.text);
                  },
                ),
              ),
            ),

            // 일정 여백 후 내용 작성 필드
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                constraints: const BoxConstraints(minHeight: 260),
                decoration: BoxDecoration(
                  color: pWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: back_grey_2, width: 1.5),
                  boxShadow: [BoxShadow(offset: const Offset(0, 3), color: pBackGrey2, blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '내용  ·  태그: <b> <i> <size=24> <color=#hex> <img>URL</img> <br>',
                      style: custom(13, FontWeight.w400, font_grey),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: content,
                      hint: '프로젝트 소개 내용을 작성하세요',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      hintColor: font_grey,
                      maxLine: null,
                      action: () {
                        manageController.changeProjectField('content', content.text);
                      },
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
}
