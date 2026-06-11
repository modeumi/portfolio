import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class HomeNote extends ConsumerStatefulWidget {
  const HomeNote({super.key});

  @override
  ConsumerState<HomeNote> createState() => _HomeNoteState();
}

class _HomeNoteState extends ConsumerState<HomeNote> with RiverpodMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.withLoading(() async {
        await noteController.getNotes();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: color_black)),
            ),
            child: Row(
              spacing: 10,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(10), child: SvgPicture.asset('assets/images/note.svg')),
                ),
                Text('노트', style: black(18, FontWeight.w600)),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    noteController.setNoteId();
                    noteController.runAutosave();
                    context.push('/note_write');
                  },
                  child: Icon(Icons.add, size: 30),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: noteState.noteList.isEmpty
                  ? Center(child: Text('작성된 노트가 없습니다.', style: black(18, FontWeight.w500)))
                  : Column(
                      spacing: 5,
                      children: [
                        for (var i in noteState.noteList.take(3))
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                DateTime noteCreate = DateTime.parse(i.createAt ?? '1999-12-31');
                                DateTime noteUpdate = DateTime.parse(i.updateAt ?? '1999-12-31');
                                String noteTitle = i.title ?? '';
                                if (noteTitle == '') {
                                  noteTitle = '노트 ${noteCreate.month.toString().padLeft(2, '0')}${noteCreate.day.toString().padLeft(2, '0')}';
                                }
                                final String initial = noteTitle.trim().isNotEmpty ? noteTitle.trim().substring(0, 1) : '노';
                                return InkWell(
                                  onTap: () {
                                    layoutController.changeColor(true);
                                    noteController.setNote(i);
                                    noteController.runAutosave();
                                    context.push('/note_write');
                                  },
                                  child: Row(
                                    spacing: 10,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // 아이템 아이콘 : 제목 이니셜 아바타
                                      Container(
                                        width: 36,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(width: 1, color: pBackGrey2),
                                          // boxShadow: [BoxShadow(offset: const Offset(0, 2), blurRadius: 5, color: secondary.withValues(alpha: 0.25))],
                                        ),
                                        child: Text(initial, style: black(16, FontWeight.w800)),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(width: 1, color: pBackGrey2)),
                                          ),
                                          child: Column(
                                            spacing: 3,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(noteTitle, style: black(15, FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              Text(
                                                '최근 수정일 : ${date_to_string_yyyyMMdd('-', noteUpdate)}',
                                                style: custom(12, FontWeight.w400, font_grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
