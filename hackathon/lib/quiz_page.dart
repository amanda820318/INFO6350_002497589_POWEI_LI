import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final String quizId;

  const QuizPage({super.key, required this.quizId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool loading = true;
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  int score = 0;

  // 單選 / TF 用：選到哪一個 index
  int? selectedIndex;

  // 多選用：選到哪些 index
  final Set<int> selectedIndexes = {};

  // 計時器相關
  static const int totalSeconds = 60;
  int remainingSeconds = totalSeconds;
  Timer? _timer;
  bool timedOut = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .orderBy('order')
          .get();

      final docs = snapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      docs.shuffle(); // 題目隨機排序（作業要求）

      setState(() {
        questions = docs;
        loading = false;
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions: $e')),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    remainingSeconds = totalSeconds;
    timedOut = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds <= 0) {
        _timer?.cancel();
        _onTimeOut();
      }
    });
  }

  // 解析 correctAnswers，可以是 [0,1] 或 ["0","1"]
  List<int> _parseCorrectIndexes(Map<String, dynamic> q) {
    final raw = (q['correctAnswers'] as List<dynamic>? ?? []);

    final result = <int>[];

    for (final e in raw) {
      if (e is num) {
        result.add(e.toInt());
      } else if (e is String) {
        final parsed = int.tryParse(e);
        if (parsed != null) {
          result.add(parsed);
        }
      }
    }
    return result;
  }

  Future<void> _saveResult({
    required int finalScore,
    required bool isTimedOut,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final resultRef = FirebaseFirestore.instance
        .collection('quizResults')
        .doc(user.uid)
        .collection('attempts')
        .doc();

    await resultRef.set({
      'quizId': widget.quizId,
      'score': isTimedOut ? 0 : finalScore,
      'totalQuestions': questions.length,
      'timedOut': isTimedOut,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _onNext() async {
    final q = questions[currentIndex];

    final typeRaw = (q['type'] as String?) ?? 'single';
    final type = typeRaw.toLowerCase(); // single / tf / multiple

    final correctIndexes = _parseCorrectIndexes(q);

    bool isCorrect = false;

    if (type == 'single' || type == 'tf') {
      if (selectedIndex != null && correctIndexes.length == 1) {
        isCorrect = selectedIndex == correctIndexes.first;
      }
    } else if (type == 'multiple') {
      final user = selectedIndexes.toList()..sort();
      final correct = List<int>.from(correctIndexes)..sort();
      isCorrect = user.length == correct.length &&
          user.asMap().entries.every((e) => e.value == correct[e.key]);
    }

    if (isCorrect) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        selectedIndexes.clear();
      });
    } else {
      _timer?.cancel();
      await _saveResult(finalScore: score, isTimedOut: false);
      _showResultDialog(score);
    }
  }

  Future<void> _onTimeOut() async {
    if (timedOut) return;
    timedOut = true;

    // 時間到 → 成績固定為 0
    await _saveResult(finalScore: 0, isTimedOut: true);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Time is up!'),
        content: Text('Your score: 0 / ${questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                ..pop() // 關掉 dialog
                ..pop(); // 回到上一頁
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(int finalScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Finished'),
        content: Text('Your score: $finalScore / ${questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                ..pop() // dialog
                ..pop(); // 回上一頁
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleChoice(List<String> options) {
    return Column(
      children: List.generate(options.length, (index) {
        return RadioListTile<int>(
          title: Text(options[index]),
          value: index,
          groupValue: selectedIndex,
          onChanged: (val) {
            setState(() => selectedIndex = val);
          },
        );
      }),
    );
  }

  Widget _buildMultipleChoice(List<String> options) {
    return Column(
      children: List.generate(options.length, (index) {
        final checked = selectedIndexes.contains(index);
        return CheckboxListTile(
          title: Text(options[index]),
          value: checked,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selectedIndexes.add(index);
              } else {
                selectedIndexes.remove(index);
              }
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: Text('No questions found.'),
        ),
      );
    }

    final q = questions[currentIndex];
    final questionText =
        (q['questionText'] as String?) ?? 'No question text';
    final typeRaw = (q['type'] as String?) ?? 'single';
    final type = typeRaw.toLowerCase();
    final options = ((q['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString()))
        .toList();

    Widget answersWidget;
    if (type == 'multiple') {
      answersWidget = _buildMultipleChoice(options);
    } else {
      // single 或 tf 都用單選
      answersWidget = _buildSingleChoice(options);
    }

    final bool hasSelection =
        type == 'multiple' ? selectedIndexes.isNotEmpty : selectedIndex != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${currentIndex + 1} / ${questions.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${remainingSeconds}s',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            answersWidget,
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: hasSelection ? _onNext : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
