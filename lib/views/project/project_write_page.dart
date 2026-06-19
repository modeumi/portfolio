import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/controllers/manage_controller.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/views/project/widgets/project_icon.dart';
import 'package:utility/color.dart';
import 'package:portfolio/core/widgets/app_modal.dart';
import 'package:utility/textstyle.dart';
import 'package:utility/toast_message.dart';

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

    final sel = content.selection;
    final text = content.text;
    final bool hasSelection = sel.isValid && sel.start != sel.end;
    // 선택 영역(예: src="REPLACE"의 REPLACE)이 있으면 그 자리에 토큰만 넣어 src 값을 채우고,
    // 선택이 없으면 완전한 <img> 태그를 삽입한다. (저장 시 토큰이 storage URL로 치환됨)
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
    manageController.changeProjectField('content', content.text);
    setState(() {});
  }

  // 추가/저장: 대기 중인 이미지들을 storage에 업로드 후 URL로 치환하여 저장
  void confirmDelete() {
    final String? id = manageState.project.id;
    if (id == null || id.isEmpty) return;
    showDialog(
      context: context,
      builder: (dialogContext) => ModalWidget(
        title: '프로젝트 삭제',
        content: '이 프로젝트를 삭제하시겠습니까?',
        width: 320,
        action: () async {
          Navigator.pop(dialogContext);
          try {
            await manageController.deleteProject(id);
            if (mounted) context.pop();
          } catch (_) {}
        },
        cancle: () {},
      ),
    );
  }

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
    } catch (e) {
      ToastMessage().ShowToast('저장에 실패했습니다. 잠시 후 다시 시도해주세요.');
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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // 상단: 뒤로가기
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: saving ? null : () => context.pop(),
                    child: Icon(Icons.arrow_back_ios_new, size: 28, color: color_black),
                  ),
                  if (!isNew)
                    GestureDetector(
                      onTap: saving ? null : confirmDelete,
                      child: Icon(Icons.delete_outline, size: 28, color: color_red),
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
                    Text(
                      'HTML 작성 · <h2> <h3> <p> <b> <ul><li> <img src> 등',
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
          ),
          _bottomBar(isNew),
        ],
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

  // 하단 편의 메뉴바 (이미지 추가 + 저장, 이후 도구 버튼은 왼쪽에 계속 추가 가능)
  Widget _bottomBar(bool isNew) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: pWhite,
        border: Border(top: BorderSide(color: back_grey_2, width: 1.5)),
        boxShadow: [BoxShadow(offset: const Offset(0, -2), color: pBackGrey2, blurRadius: 8)],
      ),
      child: Row(
        children: [
          // 왼쪽: 작성 도구 (이후 버튼은 여기에 추가)
          _toolButton(icon: Icons.image_outlined, label: '이미지 추가', onTap: addContentImage),
          const Spacer(),
          // 오른쪽: 저장/추가
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
    );
  }

  // 메뉴바 도구 버튼
  Widget _toolButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: back_grey_2, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(icon, size: 19, color: secondary),
            Text(label, style: custom(14, FontWeight.w600, secondary)),
          ],
        ),
      ),
    );
  }
}
