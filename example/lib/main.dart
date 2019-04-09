import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:push_notifications/push_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pushToken = '';

  final pushNotifications = PushNotifications();

  @override
  void initState() {
    super.initState();
    initPushNotifications();
  }

  Future<void> initPushNotifications() async {
    try {
      _pushToken = await pushNotifications.getPushToken();
      pushNotifications.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          print("!!!1");
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          print("!!!2");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          print("!!!3");
        },
      );
    } on PlatformException {
      _pushToken = 'Failed to get initPushNotifications.';
    }

    if (!mounted) return;

    setState(() {
      _pushToken = _pushToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_pushToken\n'),
        ),
      ),
    );
  }
}
