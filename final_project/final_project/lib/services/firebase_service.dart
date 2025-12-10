// lib/services/firebase_service.dart
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  FirebaseService._internal();
  static final FirebaseService instance = FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> init() async {
    await _auth.signInAnonymously();
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> addPostToFirestore(Map<String, dynamic> data) async {
    final id = data['id']?.toString();
    if (id == null) {
      await _firestore.collection('posts').add(data);
    } else {
      await _firestore.collection('posts').doc(id).set(data);
    }
  }

  Future<void> deletePostFromFirestore(String id) async {
    await _firestore.collection('posts').doc(id).delete();
    // TODO: Optionally delete associated images from Storage if paths are known.
  }

  Stream<List<Map<String, dynamic>>> listenPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<String> uploadImageBytes(
    List<int> bytes, {
    required String path,
    required String contentType,
  }) async {
    final ref = _storage.ref().child(path);
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }
}
