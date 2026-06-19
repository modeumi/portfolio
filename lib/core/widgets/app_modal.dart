// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로젝트 전용 공용 모달. (기존 utility ModalWidget API와 호환되는 드롭인)
// 동작 계약:
//  - select_button: true  → 단일 '확인' 버튼. 자동 pop 후 action 호출
//  - 2버튼            → 취소(자동 pop + cancle) / 확인(자동 pop 안 함, action이 직접 pop)
//  - customWidget      → 전체 대체 / contentWidget → 본문 자리 삽입
class ModalWidget extends StatefulWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final bool? select_button;
  final double? width;
  final VoidCallback action;
  final VoidCallback? cancle;
  final String? submitButtonContent;
  final String? cancleButtonContent;
  final Widget? customWidget;
  const ModalWidget({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.select_button,
    this.width,
    required this.action,
    this.cancle,
    this.submitButtonContent,
    this.cancleButtonContent,
    this.customWidget,
  });

  @override
  State<ModalWidget> createState() => _ModalWidgetState();
}

class _ModalWidgetState extends State<ModalWidget> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: widget.customWidget ?? _card(context),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        color: pWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: textColor.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: custom(20, FontWeight.w800, textColor), textAlign: TextAlign.center),
                if (widget.content != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.content!,
                    style: custom(15.5, FontWeight.w500, font_grey, null, null, 1.45),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.contentWidget != null) ...[
                  const SizedBox(height: 6),
                  widget.contentWidget!,
                ],
                const SizedBox(height: 22),
                (widget.select_button ?? false) ? _singleButton(context) : _doubleButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _singleButton(BuildContext context) {
    return _pill(
      label: '확인',
      filled: true,
      onTap: () {
        Navigator.pop(context);
        widget.action();
      },
    );
  }

  Widget _doubleButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _pill(
            label: widget.cancleButtonContent ?? '아니오',
            filled: false,
            onTap: () {
              Navigator.pop(context);
              if (widget.cancle != null) widget.cancle!();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _pill(
            label: widget.submitButtonContent ?? '예',
            filled: true,
            // 2버튼 확인은 자동 pop 하지 않음 — action이 직접 닫는다(결과 반환 등).
            onTap: () => widget.action(),
          ),
        ),
      ],
    );
  }

  Widget _pill({required String label, required bool filled, required VoidCallback onTap}) {
    return Material(
      color: filled ? secondary : back_grey_2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Text(
            label,
            style: custom(17, FontWeight.w700, filled ? pWhite : font_grey),
          ),
        ),
      ),
    );
  }
}
