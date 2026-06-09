import 'package:flutter/material.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';

// 프로젝트 아이콘 출력 (firebase storage URL / 임시 svg·이미지 asset 모두 대응)
Widget projectIcon(String? icon, double size) {
  if (icon == null || icon.isEmpty) {
    return Icon(Icons.folder_rounded, size: size * 0.8, color: color_grey);
  }
  if (icon.startsWith('http')) {
    return Image.network(icon, width: size, height: size, fit: BoxFit.cover);
  }
  if (icon.endsWith('.svg')) {
    return SvgPicture.asset(icon, width: size, height: size);
  }
  return Image.asset(icon, width: size, height: size, fit: BoxFit.cover);
}
