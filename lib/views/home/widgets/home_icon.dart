import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/textstyle.dart';

class HomeIcon extends ConsumerStatefulWidget {
  final String title;
  final String content;
  final bool showContent;
  const HomeIcon(this.title, this.content, this.showContent, {super.key});

  @override
  ConsumerState<HomeIcon> createState() => _HomeIconState();
}

class _HomeIconState extends ConsumerState<HomeIcon> with RiverpodMixin {
  final GlobalKey buttonKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: buttonKey,
      onTap: () {
        homeController.tabIcon(context, widget.title);
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
              child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(20), child: homeController.buildImage(widget.title)),
            ),
            if (widget.showContent) asText(widget.content, white(18, FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
