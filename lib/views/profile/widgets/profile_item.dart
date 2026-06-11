import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/models/profile_model.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

class ProfileItem extends ConsumerStatefulWidget {
  final ProfileModel model;
  const ProfileItem({super.key, required this.model});

  @override
  ConsumerState<ProfileItem> createState() => _ProfileItemState();
}

class _ProfileItemState extends ConsumerState<ProfileItem> with RiverpodMixin {
  @override
  Widget build(BuildContext context) {
    final String id = widget.model.id ?? '';
    final bool checked = profileState.checked.contains(id);
    final bool selected = profileState.selectedId == id && id.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pWhite,
        borderRadius: BorderRadius.circular(15),
        border: selected ? Border.all(color: secondary, width: 1.5) : null,
        boxShadow: [BoxShadow(offset: const Offset(0, 2), color: pBackGrey2, blurRadius: 5)],
      ),
      child: Row(
        children: [
          // 복사 체크박스
          Checkbox(
            value: checked,
            activeColor: secondary,
            onChanged: (_) => profileController.toggleCheck(id),
          ),
          // 이름 (탭 시 미리보기)
          Expanded(
            child: InkWell(
              onTap: () {
                profileController.setProfile(widget.model);
                context.push('/profile_detail');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.model.name == null || widget.model.name!.isEmpty ? '이름 없음' : widget.model.name!,
                        style: black(18, FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(12)),
                        child: Text('사용 중', style: white(12, FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // 사용 선택 버튼
          GestureDetector(
            onTap: () => profileController.selectProfile(id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: selected ? secondary : back_grey_2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('사용', style: custom(14, FontWeight.w700, selected ? Colors.white : font_grey)),
            ),
          ),
          // 수정
          GestureDetector(
            onTap: () {
              profileController.setProfile(widget.model);
              context.push('/profile_write');
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.edit_outlined, size: 24, color: secondary),
            ),
          ),
        ],
      ),
    );
  }
}
