import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      Random random = Random();
      int id = random.nextInt(1000);
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'mychannel',
          'mychannel',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher",
        ),
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error>>>$e');
    }
  }

  static Future<void> sendNotification() async {
    try {
      final data = <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done',
        'message': 'Your phone number is verified',
      };

      final FirebaseMessaging fcm = FirebaseMessaging.instance;
      final fcmToken = await fcm.getToken();

      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAiCaa7iM:APA91bHtmwpzCnTPhOA3zRdCuyiujA_ZGfU-gU4vpt5C9FZlBVQJ_H6xUAWHe0HefYVuHhu94vxth3R9AqtCkJY8qJODtOmPmh3tI5Z3tbiANefJ9EBD4MLgmZfEjAvwJVkKOcxkbzqB'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': 'Firebase Phone Authentication',
                  'body': 'Your phone number is verified'
                },
                'priority': 'high',
                'data': data,
                'to': fcmToken
              }));
      debugPrint('API Response::::::::::::::::::::${response.body}\n\n');
      debugPrint('Fcm Token::::::::::::::::::::$fcmToken\n\n');
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
