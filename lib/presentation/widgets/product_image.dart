import 'dart:io';

import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final image = imagePath.startsWith('assets/')
        ? Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: fit,
          )
        : Image.file(
            File(imagePath),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _ImagePlaceholder(
              width: width,
              height: height,
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: image,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.black12,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
