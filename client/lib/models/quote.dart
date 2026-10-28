import 'dhammapada_lines.dart';

class Quote {
  final String code;
  final String content;
  final String author;
  final String source;

  String get displayContent {
    if (content.contains('\n')) return content;
    final verse = dhammapadaLines[code];
    String normalize(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (source == 'Kinh Pháp Cú' &&
        verse != null &&
        normalize(verse) == normalize(content)) {
      return verse;
    }
    return content;
  }

  const Quote({
    required this.code,
    required this.content,
    this.author = '',
    this.source = '',
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    code: json['code'] as String,
    content: json['content'] as String,
    author: json['author'] as String? ?? '',
    source: json['source'] as String? ?? '',
  );
}
