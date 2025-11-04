import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

import 'package:portfolio/core/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? action;
  final double? fontSize;
  final Color? hintColor;
  final FontWeight? fontWeight;
  final bool? obscure;
  final int? maxLine;
  final int? maxLength;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.action,
    this.fontSize,
    this.hintColor,
    this.fontWeight,
    this.obscure,
    this.maxLine,
    this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String beforeText = '';
  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: TextSelectionThemeData(selectionHandleColor: primary),
      child: TextField(
        controller: widget.controller,
        style: black(widget.fontSize ?? 20, widget.fontWeight ?? FontWeight.w800),
        cursorColor: primary,
        onChanged: (value) {
          if (widget.action != null) {
            widget.action!();
          }
        },
        inputFormatters: [
          if (widget.maxLength != null) LengthLimitingFormatter(widget.maxLength!),
          if (widget.obscure ?? false) FilteringTextInputFormatter.deny(RegExp(r'\s')),
          // if (widget.inputType ?? false) FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9]')),
        ],
        maxLines: widget.maxLine,
        autofocus: false,
        obscureText: widget.obscure ?? false,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hint,
          counterText: '',
          hintStyle: custom(widget.fontSize ?? 20, widget.fontWeight ?? FontWeight.w800, widget.hintColor ?? color_grey),
          focusColor: primary,
        ),
      ),
    );
  }
}

class LengthLimitingFormatter extends TextInputFormatter {
  final int maxLength;

  LengthLimitingFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 1️⃣ 조합 중이면 그대로 반환
    if (newValue.composing.isValid) return newValue;

    // 2️⃣ maxLength 초과 시 자르기
    if (newValue.text.characters.length > maxLength) {
      final truncated = newValue.text.characters.take(maxLength).toString();
      return TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }

    // 3️⃣ 정상 범위이면 그대로 반환
    return newValue;
  }
}
