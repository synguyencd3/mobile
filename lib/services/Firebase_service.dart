import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/main.dart';

class FirebaseServices {
   final _firebaseMessaging = FirebaseMessaging.instance;
   static String? token;

   Future<void> initNotification() async {
     await _firebaseMessaging.requestPermission();

     final fCMToken = await _firebaseMessaging.getToken();
     token = fCMToken;
     print('token: $fCMToken');
   }

   void handleMessage(RemoteMessage? message) {
     if (message == null) return;

     navigatorKey.currentState?.pushNamed('/salon_detail');
   }
}