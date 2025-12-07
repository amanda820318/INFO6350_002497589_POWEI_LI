// lib/models/post.dart

class Post {
  Post({
    String? id,
    required this.title,
    required this.price,
    required this.description,
    List<String>? imageUrls,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        imageUrls = imageUrls ?? <String>[],
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final double price;
  final String description;
  final List<String> imageUrls;
  final DateTime createdAt;

  Post copyWith({
    String? id,
    String? title,
    double? price,
    String? description,
    List<String>? imageUrls,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrls: imageUrls ?? List<String>.from(this.imageUrls),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Placeholder for Firestore integration
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String? ?? '',
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
