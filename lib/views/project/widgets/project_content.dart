import 'package:flutter/material.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
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
      // <a href> 탭 시 외부 브라우저(새 탭)로 이동
      onTapUrl: (url) async {
        final uri = Uri.tryParse(url);
        if (uri == null) return false;
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      },
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
        return _FigureGallery(images: images, caption: caption);
      },
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'a':
            return {'color': '#4A90A4', 'font-weight': '600', 'text-decoration': 'none'};
          case 'h2':
            return {'font-size': '24px', 'font-weight': '800', 'margin': '18px 0 6px'};
          case 'h3':
            // style에 색을 직접 준 h3는 그 색을 존중, 아니면 기본 강조색
            final hasColor = (element.attributes['style'] ?? '').contains('color');
            return {
              'font-size': '19px',
              'font-weight': '700',
              if (!hasColor) 'color': '#4A90A4',
              'margin': '16px 0 6px',
            };
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

}

// figure: 사진들을 가로 한 줄(1장 중앙 / 2장 꽉참 / 그 이상 좌우 스크롤) + 아래 캡션 1개
// 스크롤 가능하면 잡아서 끌 수 있는 스크롤바를 표시한다.
class _FigureGallery extends StatefulWidget {
  final List<String> images;
  final String caption;
  const _FigureGallery({required this.images, required this.caption});

  @override
  State<_FigureGallery> createState() => _FigureGalleryState();
}

class _FigureGalleryState extends State<_FigureGallery> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth; // 중앙정렬/스크롤 판단용 가용 폭
          final double itemW = app_width / 2; // 고정 너비 (창 크기와 무관)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true, // 스크롤 가능할 때 항상 표시
                interactive: true, // 스크롤바를 잡아서 끌 수 있음
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 14), // 스크롤바 자리
                  child: ConstrainedBox(
                    // 사진이 적으면(1~2장) 중앙 정렬, 많으면 그대로 늘어나 스크롤
                    constraints: BoxConstraints(minWidth: w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final src in widget.images)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _shotImage(src, itemW),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.caption.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(widget.caption, style: custom(14, FontWeight.w500, font_grey), textAlign: TextAlign.center),
              ],
            ],
          );
        },
      ),
    );
  }
}

// 사진 1장: 고정 width + fitWidth (좌우 잘림 없이 높이는 원본 비율대로)
Widget _shotImage(String src, double width) {
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
