import 'package:flutter/material.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/widgets/Home/home_icon.dart';

class HomeIconField extends StatelessWidget {
  final Map<String, dynamic> iconData;
  final bool showContent;
  const HomeIconField({super.key, required this.iconData, required this.showContent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < 4; i++)
            if (iconData.length > i)
              HomeIcon(iconData.keys.toList()[i], iconData[iconData.keys.toList()[i]], showContent)
            else
              SizedBox(width: app_width / 8, height: app_width / 8),
        ],
      ),
    );
  }
}
