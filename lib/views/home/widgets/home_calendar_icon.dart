import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class HomeCalendarIcon extends StatefulWidget {
  final bool showContent;
  const HomeCalendarIcon({super.key, required this.showContent});

  @override
  State<HomeCalendarIcon> createState() => _HomeCalendarIconState();
}

class _HomeCalendarIconState extends State<HomeCalendarIcon> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          context.push('/calendar');
        },
        child: Column(
          spacing: 5,
          children: [
            Container(
              width: app_width / 8,
              height: app_width / 8,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: pWhite),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(color: primary),
                      child: Center(child: Text('${DateFormat.E('ko_KR').format(DateTime.now())}요일', style: black(15, FontWeight.w800))),
                    ),
                    Expanded(
                      child: Center(child: Text('${DateTime.now().day}', style: black(30, FontWeight.w600))),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showContent) Text('캘린더', style: white(18, FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
