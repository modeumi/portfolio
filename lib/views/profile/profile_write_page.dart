import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/controllers/manage_controller.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로필 추가/수정 페이지 (이름 + 자기소개 HTML)
class ProfileWritePage extends ConsumerStatefulWidget {
  const ProfileWritePage({super.key});

  @override
  ConsumerState<ProfileWritePage> createState() => _ProfileWritePageState();
}

class _ProfileWritePageState extends ConsumerState<ProfileWritePage> with RiverpodMixin {
  final TextEditingController name = TextEditingController();
  final TextEditingController content = TextEditingController();

  final Map<String, PickedImage> pendingImages = {}; // content 토큰 -> 업로드 대기 이미지
  int imgCounter = 0;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      name.text = profileState.profile.name ?? '';
      content.text = profileState.profile.content ?? '';
    });
  }

  @override
  void dispose() {
    name.dispose();
    content.dispose();
    super.dispose();
  }

  // content에 이미지 추가 (선택 영역이 있으면 토큰만, 없으면 <img> 태그 삽입)
  Future<void> addContentImage() async {
    final img = await manageController.pickImage();
    if (img == null) return;
    final key = '__img_${imgCounter++}__';
    pendingImages[key] = img;

    final sel = content.selection;
    final text = content.text;
    final bool hasSelection = sel.isValid && sel.start != sel.end;
    final String insert = hasSelection ? key : '<img src="$key">';
    String newText;
    int newOffset;
    if (sel.isValid && sel.start >= 0) {
      newText = text.replaceRange(sel.start, sel.end, insert);
      newOffset = sel.start + insert.length;
    } else {
      newText = text + insert;
      newOffset = newText.length;
    }
    content.text = newText;
    content.selection = TextSelection.collapsed(offset: newOffset);
    profileController.changeProfileField('content', content.text);
    setState(() {});
  }

  Future<void> save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      String contentText = content.text;
      for (final entry in pendingImages.entries) {
        if (!contentText.contains(entry.key)) continue;
        final url = await manageController.uploadImage(entry.value, 'profile/content');
        contentText = contentText.replaceAll(entry.key, url);
      }
      profileController.changeProfileField('name', name.text);
      profileController.changeProfileField('content', contentText);
      await profileController.saveProfile();
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = profileState.profile.id == null || profileState.profile.id!.isEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: pWhite),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: GestureDetector(
                      onTap: saving ? null : () => context.pop(),
                      child: Icon(Icons.arrow_back_ios_new, size: 28, color: color_black),
                    ),
                  ),

                  // 이름 필드
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: back_grey_2, borderRadius: BorderRadius.circular(14)),
                      child: CustomTextField(
                        controller: name,
                        hint: '프로필 이름 (예: 신입 개발자 소개)',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        hintColor: font_grey,
                        maxLine: 1,
                        action: () => profileController.changeProfileField('name', name.text),
                      ),
                    ),
                  ),

                  // 내용 필드
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      constraints: const BoxConstraints(minHeight: 320),
                      decoration: BoxDecoration(
                        color: pWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: back_grey_2, width: 1.5),
                        boxShadow: [BoxShadow(offset: const Offset(0, 3), color: pBackGrey2, blurRadius: 8)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('자기소개 HTML · <h2> <h3> <p> <b> <ul><li> <img src> 등', style: custom(13, FontWeight.w400, font_grey)),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: content,
                            hint: '자기소개 내용을 작성하세요',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            hintColor: font_grey,
                            maxLine: null,
                            action: () => profileController.changeProfileField('content', content.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 메뉴바
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: pWhite,
              border: Border(top: BorderSide(color: back_grey_2, width: 1.5)),
              boxShadow: [BoxShadow(offset: const Offset(0, -2), color: pBackGrey2, blurRadius: 8)],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: saving ? null : addContentImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(color: back_grey_2, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Icon(Icons.image_outlined, size: 19, color: secondary),
                        Text('이미지 추가', style: custom(14, FontWeight.w600, secondary)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                    decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(20)),
                    child: saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isNew ? '추가' : '저장', style: white(16, FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
