import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';

// 공용 로딩 표시 (페이지 단위 데이터 로드 중앙 스피너)
class LoadingView extends StatelessWidget {
  final double size;
  const LoadingView({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: secondary),
      ),
    );
  }
}
