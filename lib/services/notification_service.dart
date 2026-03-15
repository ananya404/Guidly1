import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    // Request permission (iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      
      if (token != null) {
        await saveTokenToDatabase(token);
      }

      // Handle token refresh
      _fcm.onTokenRefresh.listen(saveTokenToDatabase);

      // Handle incoming messages while in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Handle foreground notifications
        print("Message received: ${message.notification?.title}");
      });
    }
  }

  Future<void> saveTokenToDatabase(String token) async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _db.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }
}
