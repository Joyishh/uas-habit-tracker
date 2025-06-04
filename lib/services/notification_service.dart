import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  /// Inisialisasi FCM handler untuk pesan foreground
  static Future<void> initializeFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM][DEBUG] Pesan FCM diterima (foreground): title: \\${message.notification?.title}, body: \\${message.notification?.body}');
    });
  }
}
