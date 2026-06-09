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
/// `<figure>`(스크린샷 묶음)는 "사진들 가로 한 줄 + 그 아래 캡션 1개"로 렌더링한다.
class ProjectContent extends StatelessWidget {
  final String content;
  const ProjectContent(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      content,
      textStyle: custom(18, FontWeight.w400, color_black).copyWith(height: 1.5),
      // figure 단위로: 안의 사진들을 가로 한 줄로, figcaption은 그 아래 한 번만
      customWidgetBuilder: (element) {
        if (element.localName != 'figure') return null;

        final List<String> images = [];
        for (final img in element.querySelectorAll('img')) {
          final src = (img.attributes['src'] ?? '').trim();
          if (src.isEmpty || src == 'REPLACE') continue; // 미치환/빈 src는 제외
          images.add(src);
        }
        if (images.isEmpty) return null; // 이미지 없으면 기본 렌더링

        final caption = element.querySelector('figcaption')?.text.trim() ?? '';
        return _figureGallery(images, caption);
      },
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'h2':
            return {'font-size': '24px', 'font-weight': '800', 'margin': '18px 0 6px'};
          case 'h3':
            return {'font-size': '19px', 'font-weight': '700', 'color': '#4A90A4', 'margin': '16px 0 6px'};
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

  // figure: 사진들을 가로 한 줄(1장 중앙 / 2장 꽉참 / 그 이상 좌우 스크롤) + 아래 캡션 1개
  Widget _figureGallery(List<String> images, String caption) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double itemW = (w / 2) - 14; // 화면 절반에서 여백만큼 더 뺌
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  // 사진이 적으면(1~2장) 중앙 정렬, 많으면 그대로 늘어나 스크롤
                  constraints: BoxConstraints(minWidth: w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final src in images)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: SizedBox(width: itemW, child: _image(src, itemW)),
                        ),
                    ],
                  ),
                ),
              ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(caption, style: custom(14, FontWeight.w500, font_grey), textAlign: TextAlign.center),
              ],
            ],
          );
        },
      ),
    );
  }

  // 사진 1장 (로딩/에러 플레이스홀더 포함)
  Widget _image(String src, double width) {
    return ClipRRect(
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
    );
  }
}
