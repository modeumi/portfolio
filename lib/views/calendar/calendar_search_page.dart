import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/textstyle.dart';

class CalendarSearchPage extends ConsumerStatefulWidget {
  const CalendarSearchPage({super.key});

  @override
  ConsumerState<CalendarSearchPage> createState() => _CalendarSearchPageState();
}

class _CalendarSearchPageState extends ConsumerState<CalendarSearchPage> with RiverpodMixin {
  TextEditingController search = TextEditingController();
  DateTime now = DateTime.now();
  DateTime searchStart = DateTime.now();
  DateTime searchEnd = DateTime.now();
  String beforeSearch = '';
  String searchType = '';
  bool searched = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      searchStart = DateTime(now.year - 2, now.month, now.day);
      searchEnd = DateTime(now.year + 2, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 50),
      decoration: BoxDecoration(color: backSurface),
      width: app_width,
      height: app_height,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
                Text('검색', style: black(35, FontWeight.w700)),
                Text(
                  '${date_to_string_yyyyMMdd('.', searchStart)}부터 ${date_to_string_yyyyMMdd('.', searchEnd)}까지의 일정이 표시됩니다.',
                  style: custom(16, FontWeight.w500, font_grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    context.pop();
                  },
                  child: Icon(Icons.keyboard_arrow_left_sharp, size: 50),
                ),
                Expanded(
                  child: searched
                      ? searchType == 'text'
                            ? Text(beforeSearch, style: black(30, FontWeight.w500))
                            : Align(
                                alignment: AlignmentGeometry.centerLeft,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color(int.parse(beforeSearch))),
                                ),
                              )
                      : CustomTextField(
                          controller: search,
                          hint: '검색',
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          maxLine: 1,
                          action: () {
                            if (search.text == '') {
                              setState(() {
                                searched = false;
                              });
                            }
                          },
                        ),
                ),
                InkWell(
                  onTap: () async {
                    if (searched) {
                      setState(() {
                        search.text = '';
                        beforeSearch = '';
                        searchType = '';
                        searched = false;
                      });
                      calendarController.clearSearchResult();
                    } else {
                      setState(() {
                        searched = true;
                        searchType = 'text';
                        beforeSearch = search.text;
                      });
                      layoutController.withLoading(() async {
                        await calendarController.searchSchedule(searchType, beforeSearch);
                      });
                    }
                  },
                  child: searched ? Icon(Icons.close, size: 35) : Icon(Icons.search, size: 35),
                ),
              ],
            ),
          ),
          if (searched)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    for (var i in calendarState.searchSchedule.entries)
                      Column(
                        spacing: 15,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '${date_to_string_MMdd('kor', i.key)} (${getWeekdayLetter(DateTime.parse(i.key))})',
                                  style: custom(18, FontWeight.w600, font_grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: pWhite),
                            child: Column(
                              spacing: 10,
                              children: [
                                for (var model in i.value)
                                  InkWell(
                                    onTap: () {
                                      calendarController.setSchedule(model);
                                      context.push('/calendar_detail');
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          spacing: 18,
                                          children: [
                                            Flexible(
                                              flex: 2,
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Center(
                                                  child: model.allDay == true || model.date.length > 1
                                                      ? Icon(Icons.calendar_month_rounded)
                                                      : Text(reforme_time_short(':', model.startTime!), style: black(18, FontWeight.w700)),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Container(
                                                decoration: BoxDecoration(color: Color(model.colorCode!), borderRadius: BorderRadius.circular(25)),
                                                child: Text(' ', style: black(22, FontWeight.w500)),
                                              ),
                                            ),
                                            Flexible(flex: 9, child: Text(model.title!, style: black(22, FontWeight.w600))),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Flexible(flex: 2, child: SizedBox(width: double.infinity)),
                                            Flexible(flex: 1, child: SizedBox(width: double.infinity)),
                                            Flexible(
                                              flex: 9,
                                              child: Container(
                                                width: double.infinity,
                                                // padding: EdgeInsets.only(left: 5),
                                                child: Text(
                                                  model.allDay ?? false
                                                      ? '하루 종일'
                                                      : '${reforme_time_short('m:', '${model.startTime}')} - ${reforme_time_short('m:', '${model.endTime}')}',
                                                  style: custom(16, FontWeight.w400, font_grey),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(25)),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('색상', style: custom(20, FontWeight.w600, font_grey)),
                  Center(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: calendarState.paletteColorList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
                      itemBuilder: (context, index) {
                        int colorCode = calendarState.paletteColorList[index];
                        return InkWell(
                          onTap: () {
                            searched = true;
                            searchType = 'color';
                            beforeSearch = colorCode.toString();
                            layoutController.withLoading(() async {
                              await calendarController.searchSchedule(searchType, beforeSearch);
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Container(
                              decoration: BoxDecoration(color: Color(colorCode), shape: BoxShape.circle),
                            ),
                          ),
                        );
                      },
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
