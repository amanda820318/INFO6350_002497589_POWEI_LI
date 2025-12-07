import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'models/post.dart';
import 'screens/browse_posts_activity.dart';
import 'screens/fullscreen_image_screen.dart';
import 'screens/new_post_activity.dart';
import 'screens/post_detail_activity.dart';
import 'screens/login_screen.dart';
import 'services/post_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseService.instance.init(); // Optional: keep anonymous as fallback; login screen will handle email/password.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PostRepository.instance;
    return MaterialApp(
      title: 'HyperGarageSale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == null) {
            return const LoginScreen();
          }
          return BrowsePostsActivity(repository: repo);
        },
      ),
      routes: {
        '/browse': (_) => BrowsePostsActivity(repository: repo),
        '/new': (_) => NewPostActivity(repository: repo),
        '/login': (_) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail' && settings.arguments is Post) {
          return MaterialPageRoute(
            builder: (_) => PostDetailActivity(
              post: settings.arguments as Post,
            ),
          );
        }
        if (settings.name == '/image' && settings.arguments is String) {
          return MaterialPageRoute(
            builder: (_) =>
                FullscreenImageScreen(imageUrl: settings.arguments as String),
          );
        }
        return null;
      },
    );
  }
}
