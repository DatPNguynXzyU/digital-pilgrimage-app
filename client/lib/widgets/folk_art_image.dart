import 'package:flutter/material.dart';

class FolkArtImage extends StatelessWidget {
  final String name;
  final BoxFit fit;
  final String? semanticLabel;

  const FolkArtImage({
    super.key,
    required this.name,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => Image.asset(
    'images/folk/$name.png',
    fit: fit,
    semanticLabel: semanticLabel,
    errorBuilder: (_, _, _) => const Center(
      child: Icon(Icons.spa_outlined, color: Color(0xFF8B9F81), size: 42),
    ),
  );
}
