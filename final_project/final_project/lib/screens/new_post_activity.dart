// lib/screens/new_post_activity.dart
// Requires image_picker dependency in pubspec.yaml.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post.dart';
import '../services/firebase_service.dart';
import '../services/post_repository.dart';

class NewPostActivity extends StatefulWidget {
  const NewPostActivity({super.key, required this.repository});

  final PostRepository repository;

  @override
  State<NewPostActivity> createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) return;
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedImages.add(file));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final priceValue = double.parse(_priceController.text);
    final post = Post(
      title: _titleController.text.trim(),
      price: priceValue,
      description: _descriptionController.text.trim(),
    );

    final firebase = FirebaseService.instance;
    final downloadUrls = <String>[];
    for (final file in _selectedImages) {
      final bytes = await file.readAsBytes();
      final path = 'posts/${post.id}/${file.name}';
      final url = await firebase.uploadImageBytes(
        bytes,
        path: path,
        contentType: 'image/jpeg',
      );
      downloadUrls.add(url);
    }

    final postWithImages = post.copyWith(imageUrls: downloadUrls);

    await widget.repository.addPost(postWithImages);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New post added')),
    );
    _formKey.currentState!.reset();
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    setState(() => _selectedImages.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Post',
            onPressed: _submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price is required';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return 'Enter a valid number';
                    }
                    if (parsed < 0) return 'Price must be positive';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Images (up to 4)'),
                    TextButton.icon(
                      onPressed:
                          _selectedImages.length >= 4 ? null : () => _pickImage(),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final file = _selectedImages[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(file.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, index) =>
                        const SizedBox(width: 8),
                    itemCount: _selectedImages.length,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
