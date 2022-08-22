import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ask_me/providers/user_provider.dart';
import 'package:ask_me/screens/join_as_specialist.dart';
import 'package:ask_me/screens/favorite_screen.dart';
import 'package:ask_me/screens/questions_screen.dart';
import 'package:ask_me/screens/specialists_screen.dart';
import 'package:ask_me/widgets/app_drawer.dart';
import 'package:ask_me/widgets/items_slider.dart';
import 'package:ask_me/widgets/not_signed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../providers/consultancy_provider.dart';
import 'consultancy_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
//  static const routeName = '/main';
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String socketServerUrl =
      "wss://im561wc8h6.execute-api.us-east-2.amazonaws.com/dev";
  IOWebSocketChannel? channel;
  StreamController streamController = StreamController.broadcast();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    final userProv = Provider.of<UserProvider>(context, listen: false);
    if (!userProv.userIsSignd()) {
      channel = null;
    }
    if (channel == null && userProv.userIsSignd()) {
      init();
    }
  }

  init() async {
    streamController = StreamController.broadcast();
    final token = Provider.of<UserProvider>(context, listen: false).token;
    try {
      Random r = Random();
      String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));

      channel = IOWebSocketChannel.connect(
          Uri.parse('$socketServerUrl?token=Bearer $token'),
          headers: <String, String>{
            'Connection': 'Upgrade',
            'Upgrade': 'websocket',
            'Sec-websocket-version': '13',
            'Sec-websocket-key': key,
            'Sec-WebSocket-Extensions':
                'permessage-deflate; client_max_window_bits',
          });

      streamController
          .addStream(
        channel!.stream.asBroadcastStream(),
      )
          .then((value) {
        streamController.stream.listen((data) {
          //print("DataReceived1: " + data.toString());
        }, onDone: () {
          //print("Task Done1");
        }, onError: (error) {
          // print("Some Error1");
        });
      });
    } on WebSocketChannelException catch (error) {
      debugPrint("Error: " + error.toString());
    } catch (error) {
      debugPrint("Error: " + error.toString());
    }
  }

  @override
  void dispose() {
    streamController.close();
    if (channel != null) {
      channel!.sink.close();
    }

    super.dispose();
  }

  void selectNotification(String? payload) async {
    if (payload == null) return;
    debugPrint('notification payload: $payload');
    final message = jsonDecode(payload);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ConsultancyScreen(
              channel,
              streamController,
              secondUserEmail: message['email'],
              secondUserPhone: message['phone'],
              secondUserId: message['senderId'],
              secondUserProfileImage: message['senderUserProfileImageUrl'],
              secondUserName: message['name'],
            )));
  }

  @override
  void didChangeDependencies() {
    Future.delayed(Duration.zero).then((value) async {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final consultancyProvider =
          Provider.of<ConsultancyProvider>(context, listen: false);

      if (!userProv.userIsSignd()) {
        channel = null;
      }

      if (channel == null && userProv.userIsSignd()) {
        init();
      }
      if (consultancyProvider.unseenMessages.isNotEmpty) {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('logo');

        const InitializationSettings initializationSettings =
            InitializationSettings(
          android: initializationSettingsAndroid,
        );
        await flutterLocalNotificationsPlugin.initialize(initializationSettings,
            onSelectNotification: selectNotification);

        var android = const AndroidNotificationDetails('AskMe', 'AskMe Channel',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'logo',
            ticker: 'ticker');
        var ios = const IOSNotificationDetails();
        for (var message in consultancyProvider.unseenMessages) {
          var platform = NotificationDetails(android: android, iOS: ios);
          flutterLocalNotificationsPlugin.show(
            message.hashCode,
            'new_message_form'.tr + " " + message.name,
            message.content,
            platform,
            payload: jsonEncode({
              'senderId': message.senderId,
              'name': message.name,
              'email': message.email,
              'phone': message.phone,
              'senderUserProfileImageUrl': message.senderUserProfileImageUrl,
            }),
          );
        }
        consultancyProvider.clearUnseenMessages();
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Get.locale == const Locale('ar')
              ? 'assets/images/logo_text_ar.png'
              : 'assets/images/logo_text_en.png',
          fit: BoxFit.contain,
          width: 120,
          height: AppBar().preferredSize.height,
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProfileScreen(channel))),
              icon: const Icon(Icons.person)),
          IconButton(
              onPressed: userProv.userIsSignd()
                  ? () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FavoriteScreen(channel)))
                  : () => notSignedDialog(context),
              icon: const Icon(Icons.favorite)),
        ],
      ),
      drawer: AppDrawer(channel, streamController),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            ItemsSliderWidget(
              ads: [
                {
                  'image': 'assets/images/slider1.jpg',
                  'text': 'slider1_text'.tr,
                },
                {
                  'image': 'assets/images/slider2.jpg',
                  'text': 'slider2_text'.tr,
                },
              ],
            ),
            userProv.currentUser.isSpecialist
                ? Container()
                : TextButton(
                    onPressed: userProv.userIsSignd()
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => JoinAsSpecialistScreen(channel)))
                        : () => notSignedDialog(context),
                    child: Text(
                      'join_as_specialist'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context).primaryColorDark,
                          ),
                    ),
                  ),
            Card(
              margin: const EdgeInsets.all(8),
              elevation: 2,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => QuestionsScreen(channel))),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/ask.jpg',
                      height: MediaQuery.of(context).size.height / 3,
                      width: double.infinity,
                      fit: BoxFit.scaleDown,
                    ),
                    Text(
                      'write_your_question_now'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8),
              elevation: 2,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          SpecialistsScreen(channel, streamController)));
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/chat.jpg',
                      fit: BoxFit.scaleDown,
                      height: MediaQuery.of(context).size.height / 3,
                    ),
                    Text(
                      'find_and_ask_the_right_specialist'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
