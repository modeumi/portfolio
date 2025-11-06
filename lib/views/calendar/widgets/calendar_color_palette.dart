import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/riverpod_mixin.dart';

class CalendarColorPalette extends ConsumerStatefulWidget {
  const CalendarColorPalette({super.key});

  @override
  ConsumerState<CalendarColorPalette> createState() => _CalendarColorPaletteState();
}

class _CalendarColorPaletteState extends ConsumerState<CalendarColorPalette> with RiverpodMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(width: 40, height: 40, decoration: BoxDecoration()),
    );
  }
}
