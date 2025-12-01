import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class NotePage extends ConsumerStatefulWidget {
  const NotePage({super.key});

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> with RiverpodMixin {
  Map<String, dynamic> sort = {'updateAt': '수정 날짜 순', 'createAt': '만든 날짜 순', 'title': '제목'};
  String selectSort = '';
  bool sortType = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.changeColor(true);
    });
    selectSort = sort.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
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
                          Text(
                            '${noteState.noteFolder.keys.isNotEmpty ? '폴더 ${noteState.noteFolder.keys.length}개, ' : ''}노트 ${noteState.noteList.length}개',
                            style: black(20, FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    if (noteState.noteFolder.keys.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8),
                          itemBuilder: (context, index) {
                            // String key = noteState.noteFolder.keys.toList()[index];
                          },
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
                      ),
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
                  child: Center(child: SvgPicture.asset('images/note/write.svg')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
