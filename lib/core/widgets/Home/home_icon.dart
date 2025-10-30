import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/features/home/home_controller.dart';
import 'package:utility/textstyle.dart';

class HomeIcon extends ConsumerStatefulWidget {
  final String title;
  final String content;
  final bool showContent;
  const HomeIcon(this.title, this.content, this.showContent, {super.key});

  @override
  ConsumerState<HomeIcon> createState() => _HomeIconState();
}

class _HomeIconState extends ConsumerState<HomeIcon> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(homeControllerProvider.notifier);
    return GestureDetector(
      onTap: () {
        controller.tabIcon(context, widget.title);
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: app_width / 8,
              height: app_width / 8,
              child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(20), child: controller.buildImage(widget.title)),
            ),
            if (widget.showContent) Text(widget.content, style: white(18, FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
