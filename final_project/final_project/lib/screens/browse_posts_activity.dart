// lib/screens/browse_posts_activity.dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_repository.dart';

class BrowsePostsActivity extends StatelessWidget {
  const BrowsePostsActivity({super.key, required this.repository});

  final PostRepository repository;

  void _openNewPost(BuildContext context) {
    Navigator.pushNamed(context, '/new');
  }

  void _openDetail(BuildContext context, Post post) {
    Navigator.pushNamed(context, '/detail', arguments: post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Posts'),
      ),
      body: StreamBuilder<List<Post>>(
        stream: repository.postsStream,
        initialData: repository.currentPosts,
        builder: (context, snapshot) {
          final posts = snapshot.data ?? const [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Tap + to add.'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final thumbnail =
                  post.imageUrls.isNotEmpty ? post.imageUrls.first : null;
              return ListTile(
                leading: thumbnail != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _ThumbnailImage(path: thumbnail),
                      )
                    : const CircleAvatar(child: Icon(Icons.image_not_supported)),
              title: Text(post.title),
              subtitle: Text('\$${post.price.toStringAsFixed(2)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDetail(context, post),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNewPost(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final isRemote = path.startsWith('http');
    return isRemote
        ? Image.network(path, width: 56, height: 56, fit: BoxFit.cover)
        : Image.file(File(path), width: 56, height: 56, fit: BoxFit.cover);
  }
}
