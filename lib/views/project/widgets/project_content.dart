import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

/// content(HTML 본문)를 실제 HTML로 렌더링한다.
///
/// 표준 태그(`<h2> <h3> <p> <b> <ul>/<li> <span> <figure>/<figcaption> <img src> <br> ...`)는
/// 그대로 해석되고, 포트폴리오용 클래스(`pf-card` `pf-sub` `pf-feat` `pf-tags` `pf-shots`)에는
/// 기본 스타일을 입혀 준다. content 이미지는 `<img src="https://...">`(firebase storage) 형식.
///
/// `pf-shots`(스크린샷 묶음)는 가로 스크롤 Row로 렌더링한다.
class ProjectContent extends StatelessWidget {
  final String content;
  const ProjectContent(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      content,
      textStyle: custom(18, FontWeight.w400, color_black).copyWith(height: 1.5),
      // 스크린샷 묶음(pf-shots)은 가로 스크롤 Row로 직접 렌더링
      customWidgetBuilder: (element) {
        if (!element.classes.contains('pf-shots')) return null;

        // pf-shots 안의 모든 img를 각각 한 장으로 수집 (figure에 여러 장 들어가도 OK)
        // 캡션: img의 alt > 같은 figure의 figcaption 순. src가 비었거나 미치환(REPLACE)이면 건너뜀
        final List<({String src, String caption})> shots = [];
        for (final img in element.querySelectorAll('img')) {
          final src = (img.attributes['src'] ?? '').trim();
          if (src.isEmpty || src == 'REPLACE') continue;
          String caption = (img.attributes['alt'] ?? '').trim();
          if (caption.isEmpty) {
            var n = img.parent;
            while (n != null && n.localName != 'figure') {
              n = n.parent;
            }
            caption = n?.querySelector('figcaption')?.text.trim() ?? '';
          }
          shots.add((src: src, caption: caption));
        }
        if (shots.isEmpty) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double itemW = (w / 2) - 14; // 화면 절반에서 여백만큼 더 뺌
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ConstrainedBox(
                // 사진이 적으면(1~2장) 중앙 정렬, 많으면 그대로 늘어나 스크롤
                constraints: BoxConstraints(minWidth: w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in shots)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: SizedBox(width: itemW, child: _shot(s.src, s.caption, itemW)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'h2':
            return {'font-size': '24px', 'font-weight': '800', 'margin': '18px 0 6px'};
          case 'h3':
            return {'font-size': '19px', 'font-weight': '700', 'color': '#4A90A4', 'margin': '16px 0 6px'};
          case 'figcaption':
            return {'font-size': '13px', 'color': '#818181', 'text-align': 'center', 'margin': '4px 0 14px'};
        }

        final classes = element.classes;
        if (classes.contains('pf-card')) {
          return {'margin': '0 0 26px'};
        }
        if (classes.contains('pf-sub')) {
          return {'color': '#818181', 'font-size': '15px', 'margin': '0 0 10px'};
        }
        if (classes.contains('pf-tags')) {
          return {'margin': '6px 0'};
        }
        if (element.localName == 'span' && (element.parent?.classes.contains('pf-tags') ?? false)) {
          return {
            'background-color': '#EAEAEA',
            'color': '#4A90A4',
            'font-size': '14px',
            'font-weight': '600',
            'padding': '3px 9px',
            'margin': '0 6px 6px 0',
            'border-radius': '12px',
          };
        }
        return null;
      },
    );
  }

  // 스크린샷 1장: 이미지 + 캡션
  Widget _shot(String src, String caption, double width) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            src,
            width: width,
            fit: BoxFit.fitWidth,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: width,
                height: width,
                color: back_grey_2,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2),
              );
            },
            errorBuilder: (context, error, stack) => Container(
              width: width,
              height: width,
              color: back_grey_2,
              alignment: Alignment.center,
              child: Icon(Icons.broken_image_outlined, color: color_grey, size: 36),
            ),
          ),
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(caption, style: custom(13, FontWeight.w400, font_grey), textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
