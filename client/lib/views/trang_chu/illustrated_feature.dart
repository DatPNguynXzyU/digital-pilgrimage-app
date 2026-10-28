import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../widgets/folk_art_image.dart';

class IllustratedFeature extends StatelessWidget {
  final String title;
  final String subtitle;
  final String illustration;
  final VoidCallback onTap;
  final bool wide;

  const IllustratedFeature({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF9EF),
      borderRadius: BorderRadius.circular(wide ? 24 : 22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(wide ? 24 : 22),
        child: Container(
          constraints: BoxConstraints(minHeight: wide ? 128 : 176),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(wide ? 24 : 22),
            border: Border.all(color: AppTheme.border),
          ),
          padding: EdgeInsets.all(wide ? 12 : 10),
          child: wide
              ? Row(
                  children: [
                    SizedBox(
                      width: 128,
                      height: 104,
                      child: FolkArtImage(
                        name: illustration,
                        semanticLabel: title,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _label()),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.primary,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: FolkArtImage(
                          name: illustration,
                          semanticLabel: title,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _label(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _label() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppTheme.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          height: 1.25,
        ),
      ),
    ],
  );
}
