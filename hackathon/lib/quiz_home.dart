import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'quiz_page.dart';

class QuizHome extends StatelessWidget {
  final User? user;

  const QuizHome({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = user ?? FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hackathon Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome, ${currentUser?.displayName ?? 'Guest'}',
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (currentUser?.email != null)
                Text(
                  currentUser!.email!,
                  style:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QuizPage(
                        quizId: 'general_knowledge',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
