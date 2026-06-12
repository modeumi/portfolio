import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 공용 빈 상태 위젯 (아이콘 + 안내 문구)
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? sub;
  const EmptyState({super.key, required this.icon, required this.message, this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: pBackGrey2),
          const SizedBox(height: 14),
          Text(message, style: custom(17, FontWeight.w600, font_grey), textAlign: TextAlign.center),
          if (sub != null && sub!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(sub!, style: custom(13.5, FontWeight.w400, font_grey), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
