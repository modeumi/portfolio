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
                  child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(10), child: SvgPicture.asset('images/note.svg')),
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
                            child: InkWell(
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
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(width: 1, color: color_grey),
                                    ),
                                    child: ClipOval(child: Text(i.content ?? '', style: black(10, FontWeight.w400))),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(width: 1, color: pBackGrey2)),
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          String noteTitle = i.title ?? '';
                                          DateTime noteCreate = DateTime.parse(i.createAt ?? '1999-12-31');
                                          DateTime noteUpdate = DateTime.parse(i.updateAt ?? '1999-12-31');
                                          if (noteTitle == '') {
                                            noteTitle =
                                                '노트 ${noteCreate.month.toString().padLeft(2, '0')}${noteCreate.day.toString().padLeft(2, '0')}';
                                          }
                                          return Column(
                                            spacing: 3,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(noteTitle, style: black(15, FontWeight.w700)),
                                              Text('최근 수정일 : ${date_to_string_yyyyMMdd('-', noteUpdate)}'),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
