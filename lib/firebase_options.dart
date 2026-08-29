// Generated from android/app/google-services.json for project
// `mindchatgpt-444df`. For a fully managed setup (including the real iOS
// values) run `flutterfire configure` — the iOS block below reuses the
// Android web API key as a placeholder and must be regenerated before an
// iOS release.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaRQmfeBCZQbLIidn7bZQsGecQnuTBVi8',
    appId: '1:85511889110:android:52cf6fdf1e7f36562ba977',
    messagingSenderId: '85511889110',
    projectId: 'mindchatgpt-444df',
    databaseURL:
        'https://mindchatgpt-444df-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'mindchatgpt-444df.firebasestorage.app',
  );

  // Placeholder — regenerate with `flutterfire configure` before iOS release.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAaRQmfeBCZQbLIidn7bZQsGecQnuTBVi8',
    appId: '1:85511889110:android:52cf6fdf1e7f36562ba977',
    messagingSenderId: '85511889110',
    projectId: 'mindchatgpt-444df',
    databaseURL:
        'https://mindchatgpt-444df-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'mindchatgpt-444df.firebasestorage.app',
    iosBundleId: 'com.clothes.ecom',
  );
}
