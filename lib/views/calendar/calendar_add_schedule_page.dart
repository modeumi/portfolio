import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/views/calendar/widgets/calendar_builder.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class CalendarAddSchedulePage extends ConsumerStatefulWidget {
  const CalendarAddSchedulePage({super.key});

  @override
  ConsumerState<CalendarAddSchedulePage> createState() => _CalendarAddSchedulePageState();
}

class _CalendarAddSchedulePageState extends ConsumerState<CalendarAddSchedulePage> with RiverpodMixin {
  TextEditingController title = TextEditingController();
  TextEditingController note = TextEditingController();
  FixedExtentScrollController ampmController = FixedExtentScrollController();
  FixedExtentScrollController hourController = FixedExtentScrollController();
  FixedExtentScrollController minuteController = FixedExtentScrollController();

  bool openPalette = false;
  bool showCalendar = false;
  bool calendarType = false;
  bool showTime = false;
  bool allDay = false;
  bool selectType = false;

  DateTime focusedDay = DateTime.now();

  String selectDateType = '';
  String selectTimeType = '';

  String selectedAmPm = '';
  int hourType = 0;
  int minuteType = 0;

  List<String> ampm = ['오전', '오후'];
  List<int> hour = List.generate(12, (index) => (index + 1));
  List<int> minute = List.generate(60, (index) => index);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ampmController = FixedExtentScrollController(initialItem: 0);
    hourController = FixedExtentScrollController(initialItem: 0);
    minuteController = FixedExtentScrollController(initialItem: 0);
  }

  void setTime(String type) {
    String strtime = '';
    selectTimeType = type;
    if (type == 'start') {
      strtime = time_to_string('hms', calendarState.schedule.startDate!);
    } else if (type == 'end') {
      strtime = time_to_string('hms', calendarState.schedule.endDate!);
    }
    String reformTime = reforme_time_short('mkor', strtime);
    setState(() {
      selectedAmPm = reformTime.split(' ').first;
      hourType = int.tryParse(reformTime.split(' ')[1].replaceAll('시', '').padLeft(2, '0')) ?? 0;
      minuteType = int.tryParse(reformTime.split(' ').last.replaceAll('분', '')) ?? 0;
    });

    ampmController.jumpToItem(ampm.indexOf(selectedAmPm));
    hourController.jumpToItem(hour.indexOf(hourType));
    minuteController.jumpToItem(minute.indexOf(minuteType));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: app_width,
      height: app_height,
      decoration: BoxDecoration(color: back_grey_2),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(30, 50, 30, 10),
                    decoration: BoxDecoration(
                      color: pWhite,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: color_grey)),
                            ),
                            child: Row(
                              spacing: 20,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: title,
                                    hint: '제목',
                                    maxLine: 1,
                                    action: () {},
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      openPalette = true;
                                    });
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(color: Color(calendarState.schedule.colorCode!), shape: BoxShape.circle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: color_grey)),
                            ),
                            child: Column(
                              spacing: 30,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    calendarController.scheduleModelUpdate('allDay', !calendarState.schedule.allDay!);
                                    if (showTime) {
                                      setState(() {
                                        showTime = false;
                                        selectTimeType = '';
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(color: pWhite),
                                    child: Row(
                                      spacing: 15,
                                      children: [
                                        SvgPicture.asset('images/calendar/clock.svg'),
                                        Text('하루 종일', style: black(22, FontWeight.w500)),
                                        Spacer(),
                                        Switch(
                                          value: calendarState.schedule.allDay!,
                                          onChanged: (value) {
                                            calendarController.scheduleModelUpdate('allDay', !calendarState.schedule.allDay!);
                                            if (showTime) {
                                              setState(() {
                                                showTime = false;
                                                selectTimeType = '';
                                              });
                                            }
                                          },
                                          activeThumbColor: pWhite,
                                          activeTrackColor: primary,
                                          inactiveThumbColor: pWhite,
                                          inactiveTrackColor: color_grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  spacing: 10,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        spacing: 30,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (showCalendar && selectDateType == 'start') {
                                                  selectDateType = '';
                                                  showCalendar = false;
                                                } else {
                                                  selectDateType = 'start';
                                                  showCalendar = true;
                                                }
                                                if (showTime) {
                                                  selectTimeType = '';
                                                  showTime = false;
                                                }
                                              });
                                              selectType = true;
                                            },
                                            icon: Text(
                                              '${date_to_string_MMdd('kor', calendarState.schedule.startDate!)} (${getWeekdayLetter(calendarState.schedule.startDate!)})',
                                              style: black(22, FontWeight.w500),
                                            ),
                                          ),
                                          if (!calendarState.schedule.allDay!)
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (showTime && selectTimeType == 'start') {
                                                    selectTimeType = '';
                                                    showTime = false;
                                                  } else {
                                                    selectTimeType = 'start';
                                                    showTime = true;
                                                  }
                                                  if (showCalendar) {
                                                    selectDateType = '';
                                                    showCalendar = false;
                                                  }
                                                });
                                                setTime('start');
                                              },
                                              icon: Text(
                                                reforme_time_short('m:', time_to_string('hms', calendarState.schedule.startDate!)),
                                                style: black(22, FontWeight.w500),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_sharp),
                                    Expanded(
                                      child: Column(
                                        spacing: 30,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (showCalendar && selectDateType == 'end') {
                                                  selectDateType = '';
                                                  showCalendar = false;
                                                } else {
                                                  selectDateType = 'end';
                                                  showCalendar = true;
                                                }
                                                if (showTime) {
                                                  selectTimeType = '';
                                                  showTime = false;
                                                }
                                              });
                                              selectType = false;
                                            },
                                            icon: Text(
                                              '${date_to_string_MMdd('kor', calendarState.schedule.endDate!)} (${getWeekdayLetter(calendarState.schedule.startDate!)})',
                                              style: black(22, FontWeight.w500),
                                            ),
                                          ),
                                          if (!calendarState.schedule.allDay!)
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (showTime && selectTimeType == 'end') {
                                                    selectTimeType = '';
                                                    showTime = false;
                                                  } else {
                                                    selectTimeType = 'end';
                                                    showTime = true;
                                                  }

                                                  if (showCalendar) {
                                                    selectDateType = '';
                                                    showCalendar = false;
                                                  }
                                                });
                                                setTime('end');
                                              },
                                              icon: Text(
                                                reforme_time_short('m:', time_to_string('hms', calendarState.schedule.endDate!)),
                                                style: black(22, FontWeight.w500),
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
                          if (showCalendar)
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                spacing: 20,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            focusedDay = DateTime(focusedDay.year, focusedDay.month - 1, 1);
                                          });
                                        },
                                        child: Icon(Icons.keyboard_arrow_left),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              calendarType = !calendarType;
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(date_to_string_yyMM('kor', focusedDay), style: black(20, FontWeight.w500)),
                                              Icon(calendarType ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined, size: 30),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            focusedDay = DateTime(focusedDay.year, focusedDay.month + 1, 1);
                                          });
                                        },
                                        child: Icon(Icons.keyboard_arrow_right),
                                      ),
                                    ],
                                  ),
                                  TableCalendar(
                                    focusedDay: focusedDay,
                                    firstDay: DateTime(2020, 1, 1),
                                    lastDay: DateTime(2035, 12, 31),
                                    locale: 'ko-KR',
                                    headerVisible: false,
                                    daysOfWeekHeight: 30,
                                    rowHeight: 40,
                                    calendarStyle: CalendarStyle(isTodayHighlighted: false),
                                    onDaySelected: (selectedDay, focusedDay) {
                                      selectType = calendarController.scheduleDateUpdate(selectedDay, selectType);
                                    },
                                    calendarBuilders: CalendarBuilders(
                                      dowBuilder: (context, day) {
                                        switch (day.weekday) {
                                          case DateTime.sunday:
                                            return Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(left: Radius.circular(5))),
                                              child: Center(child: Text('일', style: custom(14, FontWeight.w400, color_red))),
                                            );
                                          case DateTime.saturday:
                                            return Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(right: Radius.circular(5))),
                                              child: Center(child: Text('토', style: custom(14, FontWeight.w400, color_blue))),
                                            );
                                          default:
                                            return Center(child: Text(['월', '화', '수', '목', '금'][day.weekday - 1], style: black(14, FontWeight.w400)));
                                        }
                                      },
                                      defaultBuilder: (context, day, focusedDay) {
                                        return calendarDaySelectBuild(day, calendarState.schedule.startDate!, calendarState.schedule.endDate!, false);
                                      },
                                      outsideBuilder: (context, day, focusedDay) {
                                        return calendarDaySelectBuild(day, calendarState.schedule.startDate!, calendarState.schedule.endDate!, true);
                                      },
                                      selectedBuilder: (context, day, focusedDay) {
                                        return calendarDaySelectBuild(day, calendarState.schedule.startDate!, calendarState.schedule.endDate!, false);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (showTime)
                            Container(
                              height: 200,
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CupertinoPicker(
                                      scrollController: ampmController,
                                      itemExtent: 60,
                                      onSelectedItemChanged: (index) {
                                        setState(() => selectedAmPm = ampm[index]);
                                        calendarController.scheduleTimeUpdate(selectTimeType, 'ampm', selectedAmPm);
                                      },
                                      selectionOverlay: Container(),
                                      children: ampm.map((time) => Center(child: Text(time, style: black(30, FontWeight.w700)))).toList(),
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      scrollController: hourController,
                                      itemExtent: 60,
                                      onSelectedItemChanged: (index) {
                                        setState(() => hourType = hour[index]);
                                        calendarController.scheduleTimeUpdate(selectTimeType, 'hour', hourType);
                                      },
                                      selectionOverlay: Container(),
                                      looping: true,
                                      children: hour
                                          .map((h) => Center(child: Text(h.toString().padLeft(2, ' '), style: black(30, FontWeight.w700))))
                                          .toList(),
                                    ),
                                  ),
                                  Text(':', style: black(30, FontWeight.w700)),
                                  Expanded(
                                    child: CupertinoPicker(
                                      scrollController: minuteController,
                                      itemExtent: 60,
                                      onSelectedItemChanged: (index) {
                                        setState(() => minuteType = minute[index]);
                                        calendarController.scheduleTimeUpdate(selectTimeType, 'minute', minuteType);
                                      },
                                      selectionOverlay: Container(),
                                      looping: true,
                                      children: minute
                                          .map((m) => Center(child: Text(m.toString().padLeft(2, '0'), style: black(30, FontWeight.w800))))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: color_grey)),
                            ),
                            child: Row(
                              spacing: 20,
                              children: [
                                SvgPicture.asset('images/calendar/note.svg', width: 30),
                                Expanded(
                                  child: CustomTextField(
                                    controller: note,
                                    hint: '메모',
                                    maxLine: 1,
                                    action: () {},
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 90),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: Text('취소', style: custom(25, FontWeight.w700, secondary)),
                      ),
                      InkWell(
                        onTap: () async {
                          if (title.text.trim().replaceAll(' ', '') != '') {
                            Map<String, dynamic> data = {'title': title.text, 'note': note.text};
                            bool result = await calendarController.addSchedule(data);
                            if (result) {
                              context.pop();
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ModalWidget(title: '오류', action: () {}, content: '일정 등록에 실패하였습니다.\n잠시 후 다시 시도해주세요.', select_button: true),
                              );
                            }
                          }
                        },
                        child: Text('저장', style: custom(25, FontWeight.w700, secondary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (openPalette)
            GestureDetector(
              onTap: () {
                setState(() {
                  openPalette = false;
                });
              },
              child: Opacity(
                opacity: 0.4,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(color: pBackGrey),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              width: double.infinity,
              height: openPalette ? 300 : 0,
              duration: Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: 60, top: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                color: pWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            openPalette = false;
                          });
                        },
                        child: Icon(Icons.close, size: 35),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Center(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: calendarState.paletteColorList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
                          itemBuilder: (context, index) {
                            int colorCode = calendarState.paletteColorList[index];
                            return GestureDetector(
                              onTap: () {
                                calendarController.scheduleModelUpdate('color', colorCode);
                                setState(() {
                                  openPalette = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: calendarState.schedule.colorCode == colorCode ? accent : pWhite),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(color: Color(colorCode), shape: BoxShape.circle),
                                ),
                              ),
                            );
                          },
                        ),
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
