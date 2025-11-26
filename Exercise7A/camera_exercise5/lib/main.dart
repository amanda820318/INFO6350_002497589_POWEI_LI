import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as p;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Received background message: ${message.messageId}');
}

const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for Firebase Cloud Messaging alerts.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _setupLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await _localNotificationsPlugin.initialize(initSettings);
  final androidPlugin = _localNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(_highImportanceChannel);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _setupLocalNotifications();

  final cameras = await availableCameras();
  runApp(CameraExerciseApp(camera: cameras.first));
}

class CameraExerciseApp extends StatelessWidget {
  final CameraDescription camera;

  const CameraExerciseApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: TakePictureScreen(camera: camera),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({super.key, required this.camera});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late final FaceDetector _faceDetector;
  bool _isProcessing = false;
  String? _lastResult;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,
      ),
    );
    _initMessaging();
  }

  @override
  void dispose() {
    _faceDetector.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initMessaging() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    debugPrint('FCM registration token: $token');

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _highImportanceChannel.id,
              _highImportanceChannel.name,
              channelDescription: _highImportanceChannel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            ),
          ),
        );
      }
      if (!mounted) return;
      final body = notification?.body ?? 'Received a push message.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body)));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (!mounted) return;
      final body = message.notification?.body ?? 'Opened a push notification.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body)));
    });
  }

  Future<bool> _detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);
    return faces.isNotEmpty;
  }

  Future<String> _uploadImage(XFile image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
    final ref = FirebaseStorage.instance.ref().child('uploads').child(fileName);
    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }

  Future<void> _handleTakePicture() async {
    setState(() {
      _isProcessing = true;
      _lastResult = null;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final hasFace = await _detectFaces(image.path);
      final downloadUrl = await _uploadImage(image);

      if (!mounted) return;
      final resultText = hasFace
          ? 'Face detected. Uploaded to Firebase Storage.'
          : 'No face detected. Uploaded to Firebase Storage.';
      _lastResult = resultText;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultText)));

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
            hasFace: hasFace,
            downloadUrl: downloadUrl,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking/uploading picture: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                if (_lastResult != null && !_isProcessing)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Card(
                      color: Colors.black87.withOpacity(0.7),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _lastResult!,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _handleTakePicture,
        icon: const Icon(Icons.camera_alt),
        label: Text(_isProcessing ? 'Working...' : 'Capture'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final bool hasFace;
  final String downloadUrl;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.hasFace,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display Picture')),
      body: Column(
        children: [
          Expanded(child: Image.file(File(imagePath))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasFace ? 'Result: Face detected' : 'Result: No face detected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Uploaded to Firebase Storage:'),
                const SizedBox(height: 4),
                SelectableText(
                  downloadUrl,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
