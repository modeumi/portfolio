import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/utility.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:portfolio/core/widgets/app_modal.dart';
import 'package:utility/textstyle.dart';
import 'package:utility/toast_message.dart';
import 'package:web/web.dart' as web;

class NoteWritePage extends ConsumerStatefulWidget {
  const NoteWritePage({super.key});

  @override
  ConsumerState<NoteWritePage> createState() => _NoteWritePageState();
}

class _NoteWritePageState extends ConsumerState<NoteWritePage> with RiverpodMixin {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController search = TextEditingController();

  bool readOnly = false;
  bool enter = false;
  bool isSearch = false;
  bool loading = false;

  Map<String, List<String>> menus = {
    'main': ['검색', '파일로 저장'],
    'icon': ['star', 'copy', 'pdf', 'delete'],
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.withLoading(() async {
        title = TextEditingController(text: noteState.note.title);
        content = TextEditingController(text: noteState.note.content);
      });
    });

    loading = true;
  }

  void copyToClipboardWeb(String text) async {
    web.window.navigator.clipboard.writeText(text);
  }

  List<DropdownItem<String>> dropdownItems() {
    List<DropdownItem<String>> widget = [];

    for (var item in menus.entries) {
      if (item.key == 'icon') {
        DropdownItem<String> row = DropdownItem<String>(
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
                        // http 에서는 안된다는 가설이 있음 배포 후 재 테스트
                        String copy = content.text;
                        if (title.text != '' && content.text != '') {
                          copy = '${title.text}\n${content.text}';
                        } else if (content.text == '') {
                          copy = title.text;
                        } else if (title.text == '') {
                          copy = content.text;
                        }
                        web.window.navigator.clipboard.writeText(copy);
                        // Clipboard.setData(ClipboardData(text: copy));
                        ToastMessage().ShowToast('클립보드에 저장되었습니다.');
                      } else if (key == 'delete') {
                        layoutController.changeDialogState(true);
                        if (!layoutState.admin) {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                ModalWidget(width: 300, title: '권한', action: () {}, content: '해당 동작을 위한 권한이 없습니다.', select_button: true),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => ModalWidget(
                            title: '노트 삭제',
                            content: '해당 노트를 삭제하겠습니까?',
                            width: 300,
                            action: () {
                              Navigator.pop(context);
                              layoutController.changeDialogState(false);
                              layoutController.withLoading(() async {
                                await noteController.deleteNote();
                              });
                              context.pop();
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
                              ? SvgPicture.asset('assets/images/note/star_on.svg')
                              : SvgPicture.asset('assets/images/note/star_off.svg')
                        : SvgPicture.asset('assets/images/note/$key.svg'),
                  ),
              ],
            ),
          ),
        );
        widget.add(row);
      } else {
        for (var mainItem in item.value) {
          DropdownItem<String> mainWidget = DropdownItem<String>(
            value: mainItem,
            child: GestureDetector(
              onTap: () {
                if (mainItem == '검색') {
                  if (!isSearch) {
                    setState(() {
                      search.clear();
                      isSearch = true;
                    });
                  }
                } else if (mainItem == '파일로 저장') {
                  if (title.text != '' || content.text != '') {
                    showDialog(
                      context: context,
                      builder: (context) => ModalWidget(
                        title: '다운로드',
                        content: '해당 노트의 내용을 텍스트 파일로 다운로드 합니다.',
                        width: 400,
                        action: () {
                          String titleText = title.text != ''
                              ? title.text
                              : '노트 ${date_to_string_MMdd('-', noteState.note.createAt ?? '1999-12-31').replaceAll('-', '')}';
                          downloadTxt(title: titleText, content: content.text);
                          Navigator.pop(context);
                        },
                        cancle: () {
                          layoutController.changeDialogState(false);
                        },
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ModalWidget(width: 400, title: '내용없음', action: () {}, content: '작성된 내용이 없어 텍스트 파일로 저장할 수 없습니다.', select_button: true),
                    );
                  }
                }
                Navigator.pop(context);
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
        if (layoutState.dialogOpen) {
          layoutController.changeDialogState(false);
        }
        if (isSearch) {
          isSearch = false;
        }
        layoutController.withLoading(() async {
          await noteController.saveNote();
          await noteController.getNotes();
        });
        if (didPop && !isSearch) return;
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
                    child: SvgPicture.asset('assets/images/top_back.svg', width: 30),
                  ),
                  Expanded(
                    child: isSearch
                        ? CustomTextField(
                            controller: search,
                            hint: '검색',
                            fontSize: 27,
                            hintColor: font_grey,
                            maxLine: 1,
                            fontWeight: FontWeight.w700,
                            action: () {},
                          )
                        : CustomTextField(
                            controller: title,
                            hint: '제목',
                            fontSize: 27,
                            hintColor: font_grey,
                            maxLine: 1,
                            fontWeight: FontWeight.w700,
                            readOnly: readOnly,
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
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: readOnly ? back_grey_2 : pWhite),
                      child: SvgPicture.asset('assets/images/note/readOnly.svg'),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: false,
                      items: dropdownItems(),
                      onChanged: (value) {},
                      customButton: SvgPicture.asset('assets/images/menu_dot.svg'),
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: pWhite),
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!readOnly && isSearch) {
                            setState(() {
                              isSearch = false;
                              search.clear();
                            });
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: (readOnly || isSearch)
                              ? SingleChildScrollView(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        for (var i in splitAndKeep(content.text, search.text))
                                          TextSpan(
                                            text: i,
                                            style: custom(
                                              20,
                                              FontWeight.w500,
                                              textColor,
                                            ).copyWith(backgroundColor: i == search.text ? primary : pWhite),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                              : CustomTextField(
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
                    ),
                    if (enter && !readOnly)
                      Row(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(noteState.isChange ? '자동저장 중' : '저장됨', style: custom(18, FontWeight.w400, textColor)),
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

List<String> splitAndKeep(String source, String pattern) {
  // 빈 검색어는 분할하지 않고, 정규식 메타문자는 이스케이프해 FormatException 크래시 방지
  if (pattern.isEmpty) return [source];
  final escaped = RegExp.escape(pattern);
  final regex = RegExp('(?=$escaped)|(?<=$escaped)');
  return source.split(regex);
}
