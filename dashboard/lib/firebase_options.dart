// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-G0xDqeuUy7kJtvLzdcmW8-5znMFpFgA',
    appId: '1:938834651536:web:cca9a1fb2c52d18cb5eb15',
    messagingSenderId: '938834651536',
    projectId: 'sara-bdfd4',
    authDomain: 'sara-bdfd4.firebaseapp.com',
    databaseURL: 'https://sara-bdfd4-default-rtdb.firebaseio.com',
    storageBucket: 'sara-bdfd4.firebasestorage.app',
    measurementId: 'G-LXJ8C5V9XZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvYBl075nHrlI_71rCj4DERPXFDtBsRm0',
    appId: '1:938834651536:android:5eadac32f19814ebb5eb15',
    messagingSenderId: '938834651536',
    projectId: 'sara-bdfd4',
    databaseURL: 'https://sara-bdfd4-default-rtdb.firebaseio.com',
    storageBucket: 'sara-bdfd4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBovlrZuZrskGvzcwMEDKxUUNCqDcc33gU',
    appId: '1:938834651536:ios:6807d237b4cbeb97b5eb15',
    messagingSenderId: '938834651536',
    projectId: 'sara-bdfd4',
    databaseURL: 'https://sara-bdfd4-default-rtdb.firebaseio.com',
    storageBucket: 'sara-bdfd4.firebasestorage.app',
    iosBundleId: 'com.example.dashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBovlrZuZrskGvzcwMEDKxUUNCqDcc33gU',
    appId: '1:938834651536:ios:6807d237b4cbeb97b5eb15',
    messagingSenderId: '938834651536',
    projectId: 'sara-bdfd4',
    databaseURL: 'https://sara-bdfd4-default-rtdb.firebaseio.com',
    storageBucket: 'sara-bdfd4.firebasestorage.app',
    iosBundleId: 'com.example.dashboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB-G0xDqeuUy7kJtvLzdcmW8-5znMFpFgA',
    appId: '1:938834651536:web:0f3fb42ac680c6b8b5eb15',
    messagingSenderId: '938834651536',
    projectId: 'sara-bdfd4',
    authDomain: 'sara-bdfd4.firebaseapp.com',
    databaseURL: 'https://sara-bdfd4-default-rtdb.firebaseio.com',
    storageBucket: 'sara-bdfd4.firebasestorage.app',
    measurementId: 'G-J26X4P7DD6',
  );
}
