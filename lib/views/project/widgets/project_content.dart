import 'package:flutter/material.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

/// content 본문을 HTML 비슷한 태그로 해석해 위젯으로 렌더링한다.
///
/// 지원 태그
/// - `<b>...</b>`              굵게
/// - `<i>...</i>`              기울임
/// - `<size=24>...</size>`     글씨 크기
/// - `<color=#4A90A4>...</color>` 글씨 색상 (#hex 또는 기본 색 이름)
/// - `<img>https://...</img>`  firebase storage 사진 (블록)
/// - `<br>`                    줄바꿈
///
/// 태그가 없는 일반 텍스트와 `\n` 줄바꿈은 그대로 출력된다.
class ProjectContent extends StatelessWidget {
  final String content;
  const ProjectContent(this.content, {super.key});

  static const double _baseSize = 18;
  static const FontWeight _baseWeight = FontWeight.w400;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _parse());
  }

  List<Widget> _parse() {
    final List<Widget> widgets = [];
    final List<InlineSpan> spans = [];
    final List<_Override> stack = [];
    bool inImg = false;
    String imgBuffer = '';

    void flushText() {
      if (spans.isEmpty) return;
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text.rich(TextSpan(children: List.of(spans))),
        ),
      );
      spans.clear();
    }

    TextStyle effective() {
      double size = _baseSize;
      FontWeight weight = _baseWeight;
      Color color = color_black;
      bool italic = false;
      for (final o in stack) {
        if (o.size != null) size = o.size!;
        if (o.weight != null) weight = o.weight!;
        if (o.color != null) color = o.color!;
        if (o.italic) italic = true;
      }
      return custom(size, weight, color).copyWith(fontStyle: italic ? FontStyle.italic : null);
    }

    void handleText(String text) {
      if (text.isEmpty) return;
      if (inImg) {
        imgBuffer += text; // 이미지 태그 안의 텍스트는 URL
        return;
      }
      spans.add(TextSpan(text: text, style: effective()));
    }

    void handleTag(String raw) {
      final tag = raw.trim();
      if (tag.isEmpty) return;

      // 닫는 태그
      if (tag.startsWith('/')) {
        final name = tag.substring(1).split('=').first.trim().toLowerCase();
        if (name == 'img') {
          final url = imgBuffer.trim();
          if (url.isNotEmpty) widgets.add(_imageWidget(url));
          imgBuffer = '';
          inImg = false;
          return;
        }
        for (int i = stack.length - 1; i >= 0; i--) {
          if (stack[i].tag == name) {
            stack.removeAt(i);
            break;
          }
        }
        return;
      }

      final name = tag.split('=').first.trim().toLowerCase().replaceAll('/', '');
      final String? value = tag.contains('=') ? tag.substring(tag.indexOf('=') + 1).trim() : null;

      switch (name) {
        case 'br':
          spans.add(const TextSpan(text: '\n'));
          break;
        case 'b':
          stack.add(_Override(tag: 'b', weight: FontWeight.w700));
          break;
        case 'i':
          stack.add(_Override(tag: 'i', italic: true));
          break;
        case 'size':
          stack.add(_Override(tag: 'size', size: double.tryParse(value ?? '')));
          break;
        case 'color':
          stack.add(_Override(tag: 'color', color: _parseColor(value)));
          break;
        case 'img':
          flushText();
          inImg = true;
          imgBuffer = '';
          break;
        default:
          break; // 알 수 없는 태그는 무시
      }
    }

    // <...> 단위로 토큰화
    final RegExp tagReg = RegExp(r'<([^>]*)>');
    int idx = 0;
    for (final m in tagReg.allMatches(content)) {
      if (m.start > idx) handleText(content.substring(idx, m.start));
      handleTag(m.group(1) ?? '');
      idx = m.end;
    }
    if (idx < content.length) handleText(content.substring(idx));
    flushText();

    return widgets;
  }

  Widget _imageWidget(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 180,
              alignment: Alignment.center,
              color: back_grey_2,
              child: const CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (context, error, stack) => Container(
            height: 180,
            alignment: Alignment.center,
            color: back_grey_2,
            child: Icon(Icons.broken_image_outlined, color: color_grey, size: 40),
          ),
        ),
      ),
    );
  }

  Color? _parseColor(String? value) {
    if (value == null) return null;
    String v = value.replaceAll('"', '').replaceAll("'", '').trim().toLowerCase();
    if (v.startsWith('#')) {
      v = v.substring(1);
      if (v.length == 6) v = 'ff$v';
      final n = int.tryParse(v, radix: 16);
      return n == null ? null : Color(n);
    }
    const named = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Color(0xFF4F8C6F),
      'black': Colors.black,
      'white': Colors.white,
      'grey': Color(0xFFA9A9A9),
      'gray': Color(0xFFA9A9A9),
      'orange': Color(0xFFFF6E00),
    };
    return named[v];
  }
}

class _Override {
  final String tag;
  final double? size;
  final FontWeight? weight;
  final Color? color;
  final bool italic;
  _Override({required this.tag, this.size, this.weight, this.color, this.italic = false});
}
