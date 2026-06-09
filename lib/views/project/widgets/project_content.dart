import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

/// content(HTML 본문)를 실제 HTML로 렌더링한다.
///
/// 표준 태그(`<h2> <h3> <p> <b> <ul>/<li> <span> <figure>/<figcaption> <img src> <br> ...`)는
/// 그대로 해석되고, 포트폴리오용 클래스(`pf-card` `pf-sub` `pf-feat` `pf-tags` `pf-shots`)에는
/// 기본 스타일을 입혀 준다. content 이미지는 `<img src="https://...">`(firebase storage) 형식.
class ProjectContent extends StatelessWidget {
  final String content;
  const ProjectContent(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      content,
      textStyle: custom(18, FontWeight.w400, color_black).copyWith(height: 1.5),
      customStylesBuilder: (element) {
        // 헤딩
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
        if (classes.contains('pf-tags') || classes.contains('pf-shots')) {
          return {'margin': '6px 0'};
        }
        // 기술 스택 태그(span)를 칩처럼
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
}
