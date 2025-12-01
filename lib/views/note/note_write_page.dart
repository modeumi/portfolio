import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';
import 'package:utility/toast_message.dart';

class NoteWritePage extends ConsumerStatefulWidget {
  const NoteWritePage({super.key});

  @override
  ConsumerState<NoteWritePage> createState() => _NoteWritePageState();
}

class _NoteWritePageState extends ConsumerState<NoteWritePage> with RiverpodMixin {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  bool readOnly = false;
  bool enter = false;

  Map<String, List<String>> menus = {
    'main': ['검색', '페이지 설정', '표지설정', '전체화면'],
    'icon': ['star', 'copy', 'pdf', 'delete'],
  };

  List<DropdownMenuItem<String>> dropdownItems() {
    List<DropdownMenuItem<String>> widget = [];

    for (var item in menus.entries) {
      if (item.key == 'icon') {
        DropdownMenuItem<String> row = DropdownMenuItem<String>(
          value: item.key,
          child: DottedBorder(
            options: CustomPathDottedBorderOptions(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              color: color_black,
              strokeWidth: 1,
              dashPattern: [2, 4],
              customPath: (size) => Path()
                ..moveTo(0, 0)
                ..relativeLineTo(size.width, 0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var key in item.value)
                  InkWell(
                    onTap: () {
                      if (key == 'star') {
                        bool isBookmark = noteState.note.bookmark ?? false;
                        noteController.changeNoteState(key, !isBookmark);
                      } else if (key == 'copy') {
                        String copy = content.text;
                        if (title.text != '' && content.text != '') {
                          copy = '${title.text}\n${content.text}';
                        } else if (content.text == '') {
                          copy = title.text;
                        } else if (title.text == '') {
                          copy = content.text;
                        }
                        Clipboard.setData(ClipboardData(text: copy));
                        // ToastMessage().ShowToast('클립보드에 저장되었습니다.');
                      } else if (key == 'delete') {
                        layoutController.changeDialogState(true);
                        showDialog(
                          context: context,
                          builder: (context) => ModalWidget(
                            title: '노트 삭제',
                            content: '해당 노트를 삭제하겠습니까?',
                            width: 300,
                            action: () {
                              Navigator.pop(context);
                              layoutController.changeDialogState(false);
                              // 삭제 로직 (저장됫는지 확인 - (저장됫다면 삭제) - 뒤로가기)
                            },
                            cancle: () {
                              layoutController.changeDialogState(false);
                            },
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: key == 'star'
                        ? noteState.note.bookmark ?? false
                              ? SvgPicture.asset('images/note/star_on.svg')
                              : SvgPicture.asset('images/note/star_off.svg')
                        : SvgPicture.asset('images/note/$key.svg'),
                  ),
              ],
            ),
          ),
        );
        widget.add(row);
      } else {
        for (var mainItem in item.value) {
          DropdownMenuItem<String> mainWidget = DropdownMenuItem<String>(
            value: mainItem,
            child: GestureDetector(
              onTap: () {
                print(mainItem);
              },
              child: SizedBox(width: 300, child: Text(mainItem, style: black(20, FontWeight.w500))),
            ),
          );
          widget.add(mainWidget);
        }
      }
    }

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: layoutState.dialogOpen,
      onPopInvokedWithResult: (didPop, result) {
        noteController.stopAutosave();
        if (didPop) return;
        if (layoutState.dialogOpen) {
          layoutController.changeDialogState(false);
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: back_grey_2),
        child: Column(
          spacing: 20,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(30, 50, 30, 10),
              decoration: BoxDecoration(color: pWhite),
              child: Row(
                spacing: 10,
                children: [
                  InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: SvgPicture.asset('images/top_back.svg', width: 30),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: title,
                      hint: '제목',
                      fontSize: 27,
                      hintColor: font_grey,
                      maxLine: 1,
                      fontWeight: FontWeight.w700,
                      action: () {
                        noteController.enterText();
                        noteController.changeNoteState('title', title.text);
                        setState(() {
                          enter = true;
                        });
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        readOnly = !readOnly;
                      });
                    },
                    child: SvgPicture.asset('images/note/readOnly.svg'),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: false,
                      items: dropdownItems(),
                      onChanged: (value) {},
                      customButton: SvgPicture.asset('images/menu_dot.svg'),
                      menuItemStyleData: MenuItemStyleData(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                      buttonStyleData: ButtonStyleData(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                      dropdownStyleData: DropdownStyleData(
                        padding: EdgeInsets.all(10),
                        width: 300,
                        offset: Offset(double.infinity, 0),
                        decoration: BoxDecoration(
                          color: back_grey_2,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: color_grey, offset: Offset(0, 3), blurRadius: 10)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: pWhite),
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CustomTextField(
                          controller: content,
                          hint: '',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          action: () {
                            noteController.enterText();
                            noteController.changeNoteState('content', content.text);
                            setState(() {
                              enter = true;
                            });
                          },
                        ),
                      ),
                    ),
                    if (enter)
                      Row(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(noteState.isChange ? '자동저장 중' : '저장됨', style: black(18, FontWeight.w400)),
                          noteState.isChange
                              ? LoadingAnimationWidget.fallingDot(color: primary, size: 25)
                              : Icon(Icons.check, color: primary, size: 25),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Container(height: 50),
          ],
        ),
      ),
    );
  }
}
