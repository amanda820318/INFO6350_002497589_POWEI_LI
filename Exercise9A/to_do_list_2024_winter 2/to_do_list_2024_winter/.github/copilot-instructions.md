# AI Coding Agent Instructions for ToDoList-2024-Winter

## Project Overview
This is a Flutter-based project designed to manage to-do lists. It uses the FlutterFlow framework and integrates Firebase for backend services. The project is structured to support multiple platforms, including Android, iOS, and web.

### Key Components
- **UI Components**: Located in `lib/`, divided into feature-specific directories such as `auth/`, `to_do_list/`, and `new_to_do_item/`.
- **Backend Integration**: Firebase services are used for authentication (`firebase_auth`), database (`cloud_firestore`), and storage (`firebase_storage`).
- **Routing**: Managed using the `go_router` package.
- **State Management**: Uses the `provider` package.
- **Assets**: Organized under `assets/` for images, fonts, videos, and more.

## Developer Workflows

### Setting Up the Project
1. Ensure you have Flutter installed and set to the `stable` channel.
2. Run `flutter pub get` to fetch dependencies.
3. Use `flutter run` to start the application.

### Testing
- Tests are located in the `test/` directory.
- Run tests using:
  ```bash
  flutter test
  ```

### Debugging
- Use `flutter run` with the `--debug` flag for debugging.
- Firebase logs can be monitored in the Firebase Console.

### Building
- Android: `flutter build apk`
- iOS: `flutter build ios`
- Web: `flutter build web`

## Project-Specific Conventions

### File Organization
- **Feature-Based Structure**: Each feature (e.g., `auth`, `to_do_list`) has its own directory under `lib/`.
- **Widget Files**: Follow the naming convention `<feature>_widget.dart`.

### Code Style
- Follow Flutter's default linting rules (`flutter_lints` package).
- Use `flutter format` to maintain consistent formatting.

### Firebase Integration
- Firebase configuration files are located in the `firebase/` directory.
- Ensure Firebase services are initialized in `lib/main.dart`.

### Asset Management
- Declare all assets in `pubspec.yaml` under the `flutter.assets` section.
- Use the `cached_network_image` package for loading images efficiently.

## External Dependencies
- **Firebase**: Core backend services.
- **Google Maps**: For location-based features.
- **Dio**: For HTTP requests.
- **Shared Preferences**: For local storage.

## Examples

### Adding a New Feature
1. Create a new directory under `lib/` for the feature.
2. Add a widget file following the `<feature>_widget.dart` naming convention.
3. Update `lib/index.dart` to export the new feature.

### Using Firebase
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

void addToDoItem(String title) {
  firestore.collection('to_do_items').add({'title': title, 'created_at': DateTime.now()});
}
```

### Routing Example
```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/to_do_list',
      builder: (context, state) => ToDoListWidget(),
    ),
  ],
);
```

## Notes
- Ensure all new features are tested and documented.
- Follow the existing project structure and conventions to maintain consistency.