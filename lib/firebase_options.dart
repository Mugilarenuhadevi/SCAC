import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-_yhvnHGZDkBeizfc7zEiwoFbRzsm2-M',
    authDomain: 'smartairaqi.firebaseapp.com',
    databaseURL: 'https://smartairaqi-default-rtdb.firebaseio.com',
    projectId: 'smartairaqi',
    storageBucket: 'smartairaqi.firebasestorage.app',
    messagingSenderId: '667052066618',
    appId: '1:667052066618:web:097783bc89bd4c69493203',
    measurementId: 'G-ER6DSQ83SD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-_yhvnHGZDkBeizfc7zEiwoFbRzsm2-M',
    authDomain: 'smartairaqi.firebaseapp.com',
    databaseURL: 'https://smartairaqi-default-rtdb.firebaseio.com',
    projectId: 'smartairaqi',
    storageBucket: 'smartairaqi.firebasestorage.app',
    messagingSenderId: '667052066618',
    appId: '1:667052066618:web:097783bc89bd4c69493203',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-_yhvnHGZDkBeizfc7zEiwoFbRzsm2-M',
    authDomain: 'smartairaqi.firebaseapp.com',
    databaseURL: 'https://smartairaqi-default-rtdb.firebaseio.com',
    projectId: 'smartairaqi',
    storageBucket: 'smartairaqi.firebasestorage.app',
    messagingSenderId: '667052066618',
    appId: '1:667052066618:web:097783bc89bd4c69493203',
  );
}
