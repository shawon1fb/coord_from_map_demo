// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_map_coord/view/page/button_page/button_page.dart';
import 'package:flutter_google_map_coord/view/page/map/map_click.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'device_model.dart';
import 'firestore_model.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel1', // id
    'High Importance Notifications1', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    title = notification.title ?? "";
    body = notification.body ?? "";

    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(


          android: AndroidNotificationDetails(
            // channelId ?? 'your channel id',
            'your channel id',
            'your channel name',
            'your channel description',
            sound: RawResourceAndroidNotificationSound('sound'),
            autoCancel: false,
            playSound: true,
            enableVibration: true,
            ledOnMs: 1,
            ledOffMs: 1,

            priority: Priority.high,
            importance: Importance.max,
            color: Color(0xff198C5F),
            // ledColor: Colors.green,

            icon: "app_icon_4",
            //icon: "food",
            // largeIcon: DrawableResourceAndroidBitmap("logoramadan"),
            // ongoing: true,
          ),
        ));
  }
}
String title = "";
String body = "";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

 await init();
  runApp(MyApp());
}


Future<void> init() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon_4');

  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,

  );

  final InitializationSettings initializationSettings =
  InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}


Future selectNotification(String? payload) async {
  //Handle notification tapped logic here

  print("local notification payload");
  print(payload);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: () => GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ButtonPage(),
        // home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    // this.title,
  }) : super(key: key);

  //final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  getToken() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) async {
      print("fcmToken:=> $value");
      await DeviceModel.getInstance.getInfo(value);
      await DeviceModel.getInstance.saveDataToFireBase();
    });
  }



  getNotification() async {
    NotificationAppLaunchDetails? d =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    print(d);
  }

  Future<void> showInsistentNotification() async {
    const int insistentFlag = 4;
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            "channel_id", 'Channel Name', "Channel Description",
            importance: Importance.max,
            priority: Priority.high,
            ticker: "ticker",
            additionalFlags: Int32List.fromList(<int>[insistentFlag]));
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Flutter Local Notification',
        'Flutter Insistent Notification', notificationDetails,
        payload: 'Destination Screen(Insistent Notification)');
  }

  @override
  void initState() {
    super.initState();
    getNotification();
    getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        title = notification.title ?? "";
        body = notification.body ?? "";
        if (mounted) setState(() {});

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                // channelId ?? 'your channel id',
                'your channel id',
                'your channel name',
                'your channel description',
                sound: RawResourceAndroidNotificationSound('sound'),
                autoCancel: false,
                playSound: true,
                enableVibration: true,
                ledOnMs: 1,
                ledOffMs: 1,

                priority: Priority.high,
                importance: Importance.max,
                color: Color(0xff198C5F),
                // ledColor: Colors.green,

                icon: "app_icon_4",
                //icon: "food",
                // largeIcon: DrawableResourceAndroidBitmap("logoramadan"),
                // ongoing: true,
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        title = notification.title ?? "";
        body = notification.body ?? "";
        if (mounted) setState(() {});

        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title ?? ""),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body ?? "")],
                  ),
                ),
              );
            });
      }
    });
  }

  void showNotification() {
    setState(() {
      _counter++;
    });
    flutterLocalNotificationsPlugin.show(
      0,
      "Testing s  $_counter",
      "How you doin ?",
      NotificationDetails(
        android: AndroidNotificationDetails(
          // channelId ?? 'your channel id',
          'your channel id',
          'your channel name',
          'your channel description',
          sound: RawResourceAndroidNotificationSound('sound'),
          autoCancel: false,
          playSound: true,
          enableVibration: true,
          ledOnMs: 1,
          ledOffMs: 1,

          priority: Priority.high,
          importance: Importance.max,
          color: Color(0xff198C5F),
          // ledColor: Colors.green,

          icon: "app_icon_4",
          //icon: "food",
          // largeIcon: DrawableResourceAndroidBitmap("logoramadan"),
          // ongoing: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget.title"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
            "Title : "+  title,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
             "body : "+ body,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showInsistentNotification,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
