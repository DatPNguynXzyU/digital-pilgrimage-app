import 'package:flutter/material.dart';

class ContentThumbnail extends StatelessWidget {
  final String url;
  final IconData icon;
  final BoxFit fit;
  const ContentThumbnail({
    super.key,
    required this.url,
    required this.icon,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(icon, color: const Color(0xFF553A28));
    return url.isEmpty
        ? fallback
        : Image.network(url, fit: fit, errorBuilder: (_, _, _) => fallback);
  }
}
