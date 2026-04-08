import 'package:flutter/material.dart';

import 'package:chatgpt_clone/shared/widgets/adaptive_image.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  const ImageViewerScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: buildAdaptiveImage(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
