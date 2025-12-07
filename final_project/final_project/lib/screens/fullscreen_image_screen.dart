// lib/screens/fullscreen_image_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';

class FullscreenImageScreen extends StatelessWidget {
  const FullscreenImageScreen({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isRemote = imageUrl.startsWith('http');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Preview',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: isRemote
            ? Image.network(imageUrl)
            : Image.file(File(imageUrl)),
      ),
    );
  }
}
