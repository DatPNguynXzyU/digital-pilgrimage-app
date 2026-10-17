class Quote {
  final String code;
  final String content;
  final String author;
  final String source;

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
