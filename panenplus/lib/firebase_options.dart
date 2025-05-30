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
    apiKey: 'AIzaSyDiMguu99J9eSx6SrFb-o8ZW1jdEzjzSb0',
    appId: '1:68915102182:web:7264a2d8553d347adb9627',
    messagingSenderId: '68915102182',
    projectId: 'panenplus-1e1c4',
    authDomain: 'panenplus-1e1c4.firebaseapp.com',
    storageBucket: 'panenplus-1e1c4.firebasestorage.app',
    measurementId: 'G-88YCR464EF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCP7iWXObPe9ZQXvG1sK_WDjObKpnYinGA',
    appId: '1:68915102182:android:f851639aa38bc0fcdb9627',
    messagingSenderId: '68915102182',
    projectId: 'panenplus-1e1c4',
    storageBucket: 'panenplus-1e1c4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEVfzVm4B9kGKDI4COD_C7Vk-SC4BeI5Q',
    appId: '1:68915102182:ios:0cddb140e857fa9edb9627',
    messagingSenderId: '68915102182',
    projectId: 'panenplus-1e1c4',
    storageBucket: 'panenplus-1e1c4.firebasestorage.app',
    iosBundleId: 'com.example.panenplus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCEVfzVm4B9kGKDI4COD_C7Vk-SC4BeI5Q',
    appId: '1:68915102182:ios:0cddb140e857fa9edb9627',
    messagingSenderId: '68915102182',
    projectId: 'panenplus-1e1c4',
    storageBucket: 'panenplus-1e1c4.firebasestorage.app',
    iosBundleId: 'com.example.panenplus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDiMguu99J9eSx6SrFb-o8ZW1jdEzjzSb0',
    appId: '1:68915102182:web:47dcf4b9fe854dcbdb9627',
    messagingSenderId: '68915102182',
    projectId: 'panenplus-1e1c4',
    authDomain: 'panenplus-1e1c4.firebaseapp.com',
    storageBucket: 'panenplus-1e1c4.firebasestorage.app',
    measurementId: 'G-P1L0782Z22',
  );
}
