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
    apiKey: 'AIzaSyAgTrmgG2dIR1ISXXY6nBnrxjEvH7SC0P4',
    appId: '1:545921502298:web:a41827f10662b65f625c63',
    messagingSenderId: '545921502298',
    projectId: 'farmsync-7bbd7',
    authDomain: 'farmsync-7bbd7.firebaseapp.com',
    storageBucket: 'farmsync-7bbd7.appspot.com',
    measurementId: 'G-V3NST8P3MH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClryjquj1nzthAoH5aUhxVZOullBq4-p0',
    appId: '1:545921502298:android:4f61283f9a223c0d625c63',
    messagingSenderId: '545921502298',
    projectId: 'farmsync-7bbd7',
    storageBucket: 'farmsync-7bbd7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFR-_lvVR7pS6HXUKH0I39NoPrpKkECw0',
    appId: '1:545921502298:ios:53ef8ee93adabdd1625c63',
    messagingSenderId: '545921502298',
    projectId: 'farmsync-7bbd7',
    storageBucket: 'farmsync-7bbd7.appspot.com',
    iosBundleId: 'com.example.farmSync',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFR-_lvVR7pS6HXUKH0I39NoPrpKkECw0',
    appId: '1:545921502298:ios:53ef8ee93adabdd1625c63',
    messagingSenderId: '545921502298',
    projectId: 'farmsync-7bbd7',
    storageBucket: 'farmsync-7bbd7.appspot.com',
    iosBundleId: 'com.example.farmSync',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAgTrmgG2dIR1ISXXY6nBnrxjEvH7SC0P4',
    appId: '1:545921502298:web:6b8ab7586f199656625c63',
    messagingSenderId: '545921502298',
    projectId: 'farmsync-7bbd7',
    authDomain: 'farmsync-7bbd7.firebaseapp.com',
    storageBucket: 'farmsync-7bbd7.appspot.com',
    measurementId: 'G-0G44QB5NYR',
  );
}