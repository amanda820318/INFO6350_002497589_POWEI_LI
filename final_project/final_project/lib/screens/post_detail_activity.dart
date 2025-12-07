// lib/screens/post_detail_activity.dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/post.dart';
class PostDetailActivity extends StatelessWidget {
  const PostDetailActivity({
    super.key,
    required this.post,
  });

  final Post post;

  void _openImage(BuildContext context, String url) {
    Navigator.pushNamed(context, '/image', arguments: url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('\$${post.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(post.description),
            const SizedBox(height: 16),
            Text(
              'Images',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (post.imageUrls.isEmpty)
              const Text('No images')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.imageUrls
                    .map(
                  (url) => GestureDetector(
                    onTap: () => _openImage(context, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _DetailImage(path: url),
                    ),
                  ),
                )
                .toList(),
          ),
          ],
        ),
      ),
    );
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final isRemote = path.startsWith('http');
    return isRemote
        ? Image.network(path, width: 100, height: 100, fit: BoxFit.cover)
        : Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover);
  }
}
