import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'guest_book.dart';
import 'yes_no_selection.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Meetup')),
      body: ListView(
        children: <Widget>[
          // 🔹 標題圖片（若圖片遺失不會出錯）
          Image.asset(
            'assets/codelab.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          // 🔹 活動資訊
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),

          // 🔹 Debug 狀態顯示（方便檢查 provider 狀態）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Builder(
              builder: (context) {
                String probe;
                bool? loggedInValue;
                try {
                  final appState = context.watch<ApplicationState>();
                  loggedInValue = appState.loggedIn;
                  probe = 'Provider OK';
                } catch (e) {
                  probe = 'Provider MISSING: $e';
                }
                return Text('Debug • $probe • loggedIn=${loggedInValue ?? 'N/A'}');
              },
            ),
          ),

          // 🔹 登入 / 登出 按鈕
          Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
              loggedIn: appState.loggedIn,
              signOut: () => FirebaseAuth.instance.signOut(),
            ),
          ),

          const Divider(height: 24),

          // 🔹 出席統計 & 出席選項
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                switch (appState.attendees) {
                  1 => const Paragraph('1 person going'),
                  >= 2 => Paragraph('${appState.attendees} people going'),
                  _ => const Paragraph('No one going'),
                },
                if (appState.loggedIn)
                  YesNoSelection(
                    state: appState.attending,
                    onSelection: (attending) => appState.attending = attending,
                  ),
              ],
            ),
          ),

          const Divider(height: 24),

          // 🔹 活動內容介紹
          const Header("What we'll be doing"),
          const Paragraph('Join us for a day full of Firebase Workshops and Pizza!'),

          // 🔹 留言區
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loggedIn) ...[
                  const Header('Discussion'),
                  GuestBook(
                    addMessage: (message) =>
                        appState.addMessageToGuestBook(message),
                    messages: appState.guestBookMessages,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
