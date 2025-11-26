import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 新增這行：為了使用 kIsWeb
import 'package:firebase_auth/firebase_auth.dart'; // 【新增】為了使用 FirebaseAuth.instance.signOut()

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  print('=== 1. 開始初始化 ==='); // Debug 訊息

  if (kIsWeb) {
    print('=== 2. 正在初始化 Web Firebase ==='); // Debug 訊息
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAZHStH1LixCu_NWsGUbYoKLOrARgn36Pk",
          authDomain: "exercise9a.firebaseapp.com",
          projectId: "exercise9a",
          storageBucket: "exercise9a.firebasestorage.app",
          messagingSenderId: "451690927458",
          appId: "1:451690927458:web:fb02079810e92fad7e083b",
          measurementId: "G-Y5C4ZN33DX",
        ),
      );
      print('=== 3. Web Firebase 初始化成功 ==='); // Debug 訊息
    } catch (e) {
      print('=== Web Firebase 初始化失敗: $e ==='); // Debug 訊息
    }
  } else {
    print('=== 2. 正在初始化 Mobile Firebase ==='); // Debug 訊息
    await initFirebase();
    print('=== 3. Mobile Firebase 初始化成功 ==='); // Debug 訊息
  }

  print('=== 4. 正在初始化 Theme ==='); // Debug 訊息
  await FlutterFlowTheme.initialize();
  print('=== 5. Theme 初始化成功，準備啟動 App ==='); // Debug 訊息

  // 【新增這段】強制登出邏輯 (修復幽靈帳號問題)
  try {
    print('=== 正在執行強制登出... ===');
    await FirebaseAuth.instance.signOut();
    print('=== 強制登出成功！幽靈帳號已清除，應該會回到登入頁面 ===');
  } catch (e) {
    print('=== 強制登出失敗: $e ===');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late Stream<BaseAuthUser> userStream;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = toDoList2024WinterFirebaseUserStream()
      ..listen((user) {
        print('=== 收到使用者狀態更新: $user ==='); // 新增這行
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();

    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ToDoList-2024-Winter',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}