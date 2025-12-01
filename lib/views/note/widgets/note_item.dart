import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/models/note_model.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/textstyle.dart';

class NoteItem extends ConsumerStatefulWidget {
  final NoteModel model;
  const NoteItem({super.key, required this.model});

  @override
  ConsumerState<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends ConsumerState<NoteItem> {
  String updateDate() {
    String result = '';
    DateTime modelDate = DateTime.parse(widget.model.updateAt ?? '1999-12-31');
    DateTime now = DateTime.now();
    if (modelDate.year == now.year) {
      result = date_to_string_MMdd('kor', modelDate);
    } else {
      result = date_to_string_yyyyMMdd('kor', modelDate);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        Container(
          width: double.infinity,
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(offset: Offset(0, 4), color: color_black, blurRadius: 5, spreadRadius: 15)],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(widget.model.content ?? '', style: black(20, FontWeight.w400), maxLines: 6, overflow: TextOverflow.fade),
        ),
        Text(widget.model.title ?? '', style: black(20, FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
        Text(updateDate(), style: custom(18, FontWeight.w500, font_grey)),
      ],
    );
  }
}
