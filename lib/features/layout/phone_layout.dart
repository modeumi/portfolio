import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/features/layout/layout_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/loading_indicator.dart';

class PhoneLayout extends ConsumerStatefulWidget {
  final Widget child;

  const PhoneLayout(this.child, {super.key});

  @override
  ConsumerState<PhoneLayout> createState() => _PhoneLayoutState();
}

class _PhoneLayoutState extends ConsumerState<PhoneLayout> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() => ref.read(layoutControllerProvider.notifier).setPhoneInit());
  }

  @override
  Widget build(BuildContext context) {
    final layoutState = ref.watch(layoutControllerProvider);
    return Scaffold(
      backgroundColor: pBackGrey,
      body: layoutState.loading
          ? LoadingIndicator(color: pMainColor)
          : Stack(
              children: [
                if (layoutState.svgData != null)
                  Center(
                    child: SizedBox(
                      width: app_width,
                      height: app_height,
                      child: SvgPicture.string(layoutState.svgData ?? '', fit: BoxFit.fill),
                    ),
                  ),
                Center(
                  child: Container(
                    width: app_width,
                    height: app_height,
                    padding: const EdgeInsets.fromLTRB(6, 5, 10, 8),
                    child: AnimatedContainer(
                      width: app_width,
                      height: app_height,
                      duration: Duration(seconds: 1),
                      decoration: BoxDecoration(color: color_black, borderRadius: BorderRadius.circular(25)),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(25),
                        child: Stack(
                          children: [
                            widget.child,
                            Positioned(
                              top: 25,
                              left: 0,
                              right: 0,
                              child: Container(
                                width: 25,
                                height: 25,
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(color: pBackBlack, shape: BoxShape.circle),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(color: pBackGrey, shape: BoxShape.circle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
