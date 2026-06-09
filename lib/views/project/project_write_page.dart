import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/controllers/manage_controller.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/views/project/widgets/project_icon.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로젝트 추가/수정 페이지
// 아이콘·content 이미지는 선택 시 로컬에 보관만 하고, 추가/저장 버튼을 눌렀을 때 storage에 업로드한다.
class ProjectWritePage extends ConsumerStatefulWidget {
  const ProjectWritePage({super.key});

  @override
  ConsumerState<ProjectWritePage> createState() => _ProjectWritePageState();
}

class _ProjectWritePageState extends ConsumerState<ProjectWritePage> with RiverpodMixin {
  final TextEditingController title = TextEditingController();
  final TextEditingController content = TextEditingController();

  PickedImage? pendingIcon; // 업로드 대기 중인 아이콘
  final Map<String, PickedImage> pendingImages = {}; // content 토큰 -> 업로드 대기 이미지
  int imgCounter = 0;
  bool saving = false;

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

  // 아이콘 선택 (로컬 보관)
  Future<void> pickIcon() async {
    final img = await manageController.pickImage();
    if (img == null) return;
    setState(() => pendingIcon = img);
  }

  // content에 이미지 추가 (로컬 보관 + 커서 위치에 토큰 삽입)
  Future<void> addContentImage() async {
    final img = await manageController.pickImage();
    if (img == null) return;
    final key = '__img_${imgCounter++}__';
    pendingImages[key] = img;

    final tag = '<img>$key</img>';
    final sel = content.selection;
    final text = content.text;
    String newText;
    int newOffset;
    if (sel.isValid && sel.start >= 0) {
      newText = text.replaceRange(sel.start, sel.end, tag);
      newOffset = sel.start + tag.length;
    } else {
      newText = text + tag;
      newOffset = newText.length;
    }
    content.text = newText;
    content.selection = TextSelection.collapsed(offset: newOffset);
    manageController.changeProjectField('content', content.text);
    setState(() {});
  }

  // 추가/저장: 대기 중인 이미지들을 storage에 업로드 후 URL로 치환하여 저장
  Future<void> save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      // 아이콘 업로드
      if (pendingIcon != null) {
        final url = await manageController.uploadImage(pendingIcon!, 'project/icon');
        manageController.changeProjectField('icon', url);
      }
      // content 이미지 업로드 + 토큰 치환 (본문에서 지워진 토큰은 업로드 안 함)
      String contentText = content.text;
      for (final entry in pendingImages.entries) {
        if (!contentText.contains(entry.key)) continue;
        final url = await manageController.uploadImage(entry.value, 'project/content');
        contentText = contentText.replaceAll(entry.key, url);
      }

      manageController.changeProjectField('name', title.text);
      manageController.changeProjectField('content', contentText);
      await manageController.saveProject();
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => saving = false);
    }
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
            // 상단: 뒤로가기 + 추가/저장
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: saving ? null : () => context.pop(),
                    child: Icon(Icons.arrow_back_ios_new, size: 28, color: color_black),
                  ),
                  GestureDetector(
                    onTap: save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(20)),
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isNew ? '추가' : '저장', style: white(18, FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            // 아이콘 등록 필드
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: saving ? null : pickIcon,
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
                  child: Center(child: _iconPreview(icon)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '내용  ·  태그: <b> <i> <size=24> <color=#hex> <br>',
                            style: custom(13, FontWeight.w400, font_grey),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 이미지 추가 버튼 (커서 위치에 이미지 토큰 삽입)
                        GestureDetector(
                          onTap: saving ? null : addContentImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(color: back_grey_2, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                Icon(Icons.image_outlined, size: 18, color: secondary),
                                Text('이미지 추가', style: custom(14, FontWeight.w600, secondary)),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  // 아이콘 미리보기: 로컬 선택분 > 기존 icon > 플레이스홀더
  Widget _iconPreview(String? icon) {
    if (pendingIcon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(pendingIcon!.bytes, width: 74, height: 74, fit: BoxFit.cover),
      );
    }
    if (icon != null && icon.isNotEmpty) {
      return projectIcon(icon, 74);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 34, color: color_grey),
        const SizedBox(height: 6),
        Text('아이콘', style: custom(13, FontWeight.w500, font_grey)),
      ],
    );
  }
}
