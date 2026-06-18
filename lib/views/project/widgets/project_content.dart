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

  // 사진 탭 → 전체화면 확대 뷰어 (드래그 이동 + 줌 +/- / 원래대로)
  void _openImageViewer(BuildContext context, String src) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '이미지 확대',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => _ImageViewer(src: src),
      transitionBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    );
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
                            child: GestureDetector(
                              onTap: () => _openImageViewer(context, src),
                              child: _shotImage(src, itemW),
                            ),
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

// 전체화면 이미지 뷰어: 핀치/드래그 + 하단 줌 +/- / 원래대로 버튼
class _ImageViewer extends StatefulWidget {
  final String src;
  const _ImageViewer({required this.src});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  final TransformationController _controller = TransformationController();

  double get _scale => _controller.value.getMaxScaleOnAxis();

  // 화면 중앙을 기준으로 배율 설정 (1~5배)
  void _setZoom(double next) {
    final double s = next.clamp(1.0, 5.0);
    final Size size = MediaQuery.of(context).size;
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    // (cx, cy)를 고정점으로 하는 s배 확대 행렬
    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, s)
      ..setEntry(1, 1, s)
      ..setEntry(0, 3, cx * (1 - s))
      ..setEntry(1, 3, cy * (1 - s));
  }

  void _zoomIn() => _setZoom(_scale + 0.5);
  void _zoomOut() => _setZoom(_scale - 0.5);
  void _reset() => _controller.value = Matrix4.identity();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 26),
      splashRadius: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.network(
                  widget.src,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 60),
                ),
              ),
            ),
          ),
          // 닫기
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(child: _circleBtn(Icons.close, () => Navigator.pop(context))),
          ),
          // 하단 줌 컨트롤
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _circleBtn(Icons.zoom_out, _zoomOut),
                      _circleBtn(Icons.refresh, _reset),
                      _circleBtn(Icons.zoom_in, _zoomIn),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
