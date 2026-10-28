import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class TemplePhotoAlbum extends StatefulWidget {
  final List<String> images;
  const TemplePhotoAlbum({super.key, required this.images});

  @override
  State<TemplePhotoAlbum> createState() => _TemplePhotoAlbumState();
}

class _TemplePhotoAlbumState extends State<TemplePhotoAlbum> {
  int _index = 0;

  Widget _placeholder() => const ColoredBox(
    color: AppTheme.surface,
    child: Center(
      child: Icon(
        Icons.temple_buddhist_outlined,
        size: 80,
        color: AppTheme.secondary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final images = widget.images
        .where((url) => url.trim().isNotEmpty)
        .toSet()
        .toList();
    if (images.isEmpty) return _placeholder();
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          key: ValueKey(images.join('|')),
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _index = index),
          itemBuilder: (context, index) => Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(),
          ),
        ),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Colors.transparent,
                  Color(0x44000000),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(_index < images.length ? _index : 0) + 1} / ${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
