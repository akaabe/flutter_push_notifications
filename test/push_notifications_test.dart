import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_notifications/push_notifications.dart';

void main() {
  const MethodChannel channel = MethodChannel('push_notifications');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPushToken', () async {
  //   expect(await PushNotifications.platformVersion, '42');
  // });
}
