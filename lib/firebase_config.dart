// firebase_config.dart
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

/// Initializes Firebase with the appropriate platform-specific options.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
