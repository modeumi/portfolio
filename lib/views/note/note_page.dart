import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class NotePage extends ConsumerStatefulWidget {
  const NotePage({super.key});

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> with RiverpodMixin {
  Map<String, dynamic> sort = {'updateAt': '수정 날짜 순', 'createAt': '생성 날짜 순', 'title': '제목'};
  String selectSort = '';
  bool sortType = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.changeColor(true);
      layoutController.withLoading(() async {
        await noteController.getNotes();
        noteController.setSortInfo(sort.keys.first, true);
      });
    });
    selectSort = sort.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        layoutController.changeColor(false);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 60),
        decoration: BoxDecoration(color: pWhite),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('노트', style: black(35, FontWeight.w700)),
                          Text('${noteState.noteList.length}개', style: black(20, FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  buttonStyleData: ButtonStyleData(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                                  isExpanded: false,
                                  items: [
                                    for (var e in sort.entries)
                                      DropdownMenuItem(
                                        value: e.key,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 20,
                                          children: [
                                            Text(e.value, style: custom(18, FontWeight.w500, selectSort == e.key ? color_red : color_black)),
                                            SizedBox(width: 30, child: selectSort == e.key ? Icon(Icons.check, color: color_red) : SizedBox()),
                                          ],
                                        ),
                                      ),
                                  ],
                                  iconStyleData: IconStyleData(
                                    icon: Container(
                                      padding: EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        border: Border(right: BorderSide(width: 1, color: color_grey)),
                                      ),
                                      child: Row(
                                        spacing: 10,
                                        children: [
                                          Icon(Icons.sort_rounded, color: color_grey),
                                          Text(sort[selectSort], style: custom(18, FontWeight.w500, font_grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectSort = value!;
                                    });
                                    noteController.setSortInfo(selectSort, sortType);
                                  },
                                  dropdownStyleData: DropdownStyleData(
                                    padding: EdgeInsets.zero,
                                    width: 200,
                                    offset: Offset(double.infinity, 0),
                                    decoration: BoxDecoration(
                                      color: back_grey_2,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: color_grey, offset: Offset(0, 3), blurRadius: 10)],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    sortType = !sortType;
                                  });
                                  noteController.setSortInfo(selectSort, sortType);
                                },
                                child: Icon(sortType ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined, color: color_grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (noteState.noteList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 150),
                        child: Column(
                          spacing: 10,
                          children: [
                            Text('노트가 없습니다', style: black(18, FontWeight.w400)),
                            Text('노트를 작성하려면 추가 버튼을 누르세요.', style: custom(16, FontWeight.w400, font_grey)),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: noteState.noteList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 가로 3칸
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 50,
                            childAspectRatio: 0.5, // 정사각형
                          ),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                noteController.setNote(noteState.noteList[index]);
                                noteController.runAutosave();
                                context.push('/note_write');
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 10,
                                children: [
                                  Flexible(
                                    flex: 8,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: pWhite,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [BoxShadow(offset: Offset(0, 2), color: pBackGrey2, blurRadius: 5)],
                                      ),
                                      child: Text(
                                        noteState.noteList[index].content ?? '',
                                        style: black(18, FontWeight.w400),
                                        maxLines: 6,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 4,
                                    child: Builder(
                                      builder: (context) {
                                        DateTime now = DateTime.now();
                                        DateTime noteCreateDate = DateTime.parse(noteState.noteList[index].createAt ?? '1999-12-31');
                                        bool sameYear = now.year == noteCreateDate.year;
                                        String showDate = sameYear
                                            ? date_to_string_MMdd('kor', noteCreateDate)
                                            : date_to_string_yyyyMMdd('kor', noteCreateDate);
                                        return Column(
                                          children: [
                                            Text(
                                              noteState.noteList[index].title != null && noteState.noteList[index].title != ''
                                                  ? noteState.noteList[index].title!
                                                  : '노트 ${noteCreateDate.month.toString().padLeft(2, '0')}${noteCreateDate.day.toString().padLeft(2, '0')}',
                                              style: black(20, FontWeight.w700),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            asText(showDate, grey(18, FontWeight.w400)),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: app_height * 0.1),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: InkWell(
                onTap: () {
                  noteController.setNoteId();
                  noteController.runAutosave();
                  context.push('/note_write');
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: pWhite,
                    boxShadow: [BoxShadow(offset: Offset(0, 5), blurRadius: 5, color: color_grey)],
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: SvgPicture.asset('assets/images/note/write.svg')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
