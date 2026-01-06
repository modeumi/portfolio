import 'dart:html' as html;
import 'dart:convert';

void downloadTxt({required String title, required String content}) {
  final text = content;

  final bytes = utf8.encode(text);
  final blob = html.Blob([bytes], 'text/plain;charset=utf-8');

  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..download = '$title.txt'
    ..style.display = 'none';

  html.document.body!.append(anchor);
  anchor.click();

  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
