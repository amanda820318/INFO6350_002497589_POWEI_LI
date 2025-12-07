// lib/firebase_options.dart
// Manually created from android/app/google-services.json.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web FirebaseOptions not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
            'This default FirebaseOptions supports only Android. Generate options for other platforms.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA17CNcB4_eqgxb6qZFYODCLHh1RhIGN88',
    appId: '1:732126832432:android:fde3a2b3dd94831e040af5',
    messagingSenderId: '732126832432',
    projectId: 'finalproject-c5cf1',
    storageBucket: 'finalproject-c5cf1.firebasestorage.app',
  );
}
