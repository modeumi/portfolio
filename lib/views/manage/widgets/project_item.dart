import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class ProjectItem extends ConsumerStatefulWidget {
  final ProjectModel model;
  const ProjectItem({super.key, required this.model});

  @override
  ConsumerState<ProjectItem> createState() => _ProjectItemState();
}

class _ProjectItemState extends ConsumerState<ProjectItem> with RiverpodMixin {
  // 아이콘 출력 (firebase storage URL / 임시 asset 모두 대응)
  Widget buildIcon(String? icon) {
    if (icon == null || icon.isEmpty) {
      return Icon(Icons.folder_rounded, size: 30, color: color_grey);
    }
    if (icon.startsWith('http')) {
      return Image.network(icon, width: 40, height: 40, fit: BoxFit.cover);
    }
    if (icon.endsWith('.svg')) {
      return SvgPicture.asset(icon, width: 40, height: 40);
    }
    return Image.asset(icon, width: 40, height: 40, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 아이템 클릭 -> 해당 게시물로 이동
      onTap: () {
        manageController.setProject(widget.model);
        context.push('/project_detail');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: pWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(offset: Offset(0, 2), color: pBackGrey2, blurRadius: 5)],
        ),
        child: Row(
          children: [
            SizedBox(width: 40, height: 40, child: Center(child: buildIcon(widget.model.icon))),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                widget.model.name ?? '',
                style: black(20, FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            // 연필 클릭 -> 수정으로 이동
            GestureDetector(
              onTap: () {
                manageController.setProject(widget.model);
                context.push('/project_write');
              },
              child: Icon(Icons.edit_outlined, size: 26, color: secondary),
            ),
          ],
        ),
      ),
    );
  }
}
