import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:utility/loading_indicator.dart';
import 'package:utility/textstyle.dart';

class MessageField extends StatefulWidget {
  final bool type; // true : 사용자 , false : 관리자
  final bool last;
  final String time;
  final String content;
  const MessageField({super.key, required this.type, required this.content, required this.time, required this.last});

  @override
  State<MessageField> createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: widget.type ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (widget.type && widget.last) Text(widget.time, style: grey(16, FontWeight.w400)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            constraints: BoxConstraints(maxWidth: app_width * 0.7),
            decoration: BoxDecoration(color: widget.type ? primary : secondary, borderRadius: BorderRadius.circular(15)),
            child: widget.content.contains('portfolio-f7c58')
                ? Container(
                    width: app_width / 2,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: Image.network(
                      widget.content,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Container(
                          width: app_width / 2,
                          height: app_width / 2,
                          child: Center(child: LoadingIndicator(color: pWhite)),
                        );
                      },
                    ),
                  )
                : Text(widget.content, style: custom(18, FontWeight.w400, widget.type ? textColor : pWhite)),
          ),
          if (!widget.type && widget.last) Text(widget.time, style: grey(16, FontWeight.w400)),
        ],
      ),
    );
  }
}
