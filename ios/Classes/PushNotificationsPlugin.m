#import "PushNotificationsPlugin.h"
#import <push_notifications/push_notifications-Swift.h>

@implementation PushNotificationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPushNotificationsPlugin registerWithRegistrar:registrar];
}
@end
