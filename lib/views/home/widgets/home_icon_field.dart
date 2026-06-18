import 'package:flutter/material.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/views/home/widgets/home_calendar_icon.dart';
import 'package:portfolio/views/home/widgets/home_icon.dart';

class HomeIconField extends StatelessWidget {
  final Map<String, dynamic> iconData;
  final bool showContent;
  // 부족한 줄(아이콘 4개 미만)을 가운데 정렬할지 (앱스 드로어용). 기본은 좌측부터 채움(홈 메인 동일)
  const HomeIconField({super.key, required this.iconData, required this.showContent});

  @override
  Widget build(BuildContext context) {
    // 'empty'(의도적 빈칸 placeholder) 포함, 실제 항목 수만큼만 칸 생성
    final List<String> entries = iconData.keys.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double slot = constraints.maxWidth / 4;
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (final key in entries)
                SizedBox(
                  width: slot,
                  child: key == 'empty'
                      ? SizedBox(width: double.infinity, height: app_width / 8)
                      : key == 'calendar'
                      ? HomeCalendarIcon(showContent: showContent)
                      : HomeIcon(key, iconData[key], showContent),
                ),
            ],
          );
        },
      ),
    );
  }
}
