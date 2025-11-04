import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

class LoginTextfield extends StatefulWidget {
  final double width;
  final String content;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onChange;
  final ValueChanged<String>? onSubmitted;
  const LoginTextfield({
    super.key,
    required this.content,
    required this.controller,
    required this.obscure,
    required this.width,
    required this.onChange,
    this.onSubmitted,
  });

  @override
  State<LoginTextfield> createState() => _LoginTextfieldState();
}

class _LoginTextfieldState extends State<LoginTextfield> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 13),
              width: widget.width - 20,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: color_grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextSelectionTheme(
                data: TextSelectionThemeData(selectionHandleColor: primary),
                child: TextField(
                  onSubmitted: widget.onSubmitted,
                  controller: widget.controller,
                  style: black(18, FontWeight.w500),
                  cursorColor: primary,
                  onChanged: (value) {
                    widget.onChange();
                  },
                  maxLines: 1,
                  autofocus: false,
                  obscureText: widget.obscure,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '${widget.content}를 입력해주세요.',
                    hintStyle: custom(18, FontWeight.w500, color_grey),
                    focusColor: primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: pWhite),
              child: Text(widget.content, style: custom(15, FontWeight.w400, color_grey)),
            ),
          ),
        ],
      ),
    );
  }
}
