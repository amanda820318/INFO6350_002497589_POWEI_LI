// lib/services/post_repository.dart
import '../models/post.dart';
import 'firebase_service.dart';

class PostRepository {
  PostRepository._internal();
  static final PostRepository instance = PostRepository._internal();

  final FirebaseService _firebase = FirebaseService.instance;

  Stream<List<Post>> get postsStream => _firebase
      .listenPosts()
      .map((list) => list.map((data) => Post.fromMap(data)).toList());

  List<Post> get currentPosts => const [];

  Future<Post> addPost(Post post) async {
    await _firebase.addPostToFirestore(post.toMap());
    return post;
  }
}
