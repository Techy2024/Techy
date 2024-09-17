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
    apiKey: 'AIzaSyBeDS6CGv3dK9umfTc5pvf1IC-hPu3BFsE',
    appId: '1:314515395558:web:049f5401217459b6647c27',
    messagingSenderId: '314515395558',
    projectId: 'techy-login',
    authDomain: 'techy-login.firebaseapp.com',
    storageBucket: 'techy-login.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhG7nsIbEkYm7vIMqc4XJNALfAu-U3kUQ',
    appId: '1:314515395558:android:4da7ef64a2fcaa09647c27',
    messagingSenderId: '314515395558',
    projectId: 'techy-login',
    storageBucket: 'techy-login.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOnQRC_8cczk9WHWjov6tE_iXF_P4FRUo',
    appId: '1:314515395558:ios:ae7b4b5b37b3fe65647c27',
    messagingSenderId: '314515395558',
    projectId: 'techy-login',
    storageBucket: 'techy-login.appspot.com',
    iosBundleId: 'com.example.finalProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOnQRC_8cczk9WHWjov6tE_iXF_P4FRUo',
    appId: '1:314515395558:ios:ae7b4b5b37b3fe65647c27',
    messagingSenderId: '314515395558',
    projectId: 'techy-login',
    storageBucket: 'techy-login.appspot.com',
    iosBundleId: 'com.example.finalProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBeDS6CGv3dK9umfTc5pvf1IC-hPu3BFsE',
    appId: '1:314515395558:web:3bb34b5fb0df1aba647c27',
    messagingSenderId: '314515395558',
    projectId: 'techy-login',
    authDomain: 'techy-login.firebaseapp.com',
    storageBucket: 'techy-login.appspot.com',
  );
}