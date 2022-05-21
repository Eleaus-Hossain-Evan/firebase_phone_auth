import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'infastructure/service.dart';
import 'presentation/home_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  ///Onclick listener
  NotificationService.display(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _fcmInit();
  }

  Future<void> _fcmInit() async {
    FirebaseMessaging.instance.getInitialMessage();

    ///When App Running
    FirebaseMessaging.onMessage.listen((event) {
      if (kDebugMode) {
        print('\n\n!!FCM message Received!! (On Running)\n\n\n');
        print('Event: ${event.data}\n'
            'body: ${event.notification!.body}');
      }
      NotificationService.display(event);
    });

    ///When App Minimized
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (kDebugMode) {
        print('\n\n\n!!FCM message Received (On Minimize)!!\n\n\n');
        print('Event: ${event.data}\n'
            'body: ${event.notification!.body}');
      }
      NotificationService.display(event);
    });

    ///When App Destroyed
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (kDebugMode) {
        print('\n\n\n!!FCM message Received (On Destroy)!!\n\n\n');
      }
      if (value != null) {
        NotificationService.display(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Phone Auth',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: const Color(0xfffffcfc),
          ),
          home: const HomePage(),
          builder: (context, child) {
            child = MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
              child: child!,
            );
            return child;
          },
        );
      },
    );
  }
}
