import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/controllers/loading_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

class LoadingPage extends ConsumerStatefulWidget {
  const LoadingPage({super.key});

  @override
  ConsumerState<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() => ref.read(loadingControllerProvider.notifier).setLoading(context));
  }

  @override
  Widget build(BuildContext context) {
    final loadingState = ref.watch(loadingControllerProvider);
    return Scaffold(
      backgroundColor: color_black,
      body: Center(
        child: SizedBox(
          width: app_width,
          height: app_height,
          child: Column(
            spacing: 50,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome!', style: white(45, FontWeight.w700)),
              Column(
                spacing: 20,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      width: 300,
                      height: 5,
                      child: LinearProgressIndicator(
                        value: loadingState.loadingPercent / 100, // 0~1 사이 값, null이면 indeterminate 모드
                        backgroundColor: color_white,
                        color: primary,
                      ),
                    ),
                  ),
                  Text('${loadingState.loadingPercent}%', style: white(24, FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
