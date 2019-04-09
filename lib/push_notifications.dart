import 'dart:async';
import 'package:flutter/services.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);
typedef Future<dynamic> PushTokenHandler(String pushToken);

class PushNotifications {
  MessageHandler _onMessage;
  MessageHandler _onLaunch;
  MessageHandler _onResume;
  PushTokenHandler _onPushToken;

  static const _platform = const MethodChannel('push_notifications');

  Future getPushToken() async {
    try {
      return await _platform.invokeMethod('getPushToken');
    } on PlatformException catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onMessage':
        return _onMessage(call.arguments.cast<String, dynamic>());
      case 'onLaunch':
        return _onLaunch(call.arguments.cast<String, dynamic>());
      case 'onResume':
        return _onResume(call.arguments.cast<String, dynamic>());
      case 'onPushToken':
        return _onPushToken(call.arguments);
      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }

  void configure(
      {MessageHandler onMessage,
      MessageHandler onLaunch,
      MessageHandler onResume,
      PushTokenHandler onPushToken}) {
    _onMessage = onMessage;
    _onLaunch = onLaunch;
    _onResume = onResume;
    _onPushToken = onPushToken;
    _platform.setMethodCallHandler(_handleMethod);
  }
}
