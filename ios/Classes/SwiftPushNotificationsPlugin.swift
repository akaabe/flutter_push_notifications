import Flutter
import UIKit

enum PushOnState {
    case onLaunch
    case onResume
    case onMessage
}

public class SwiftPushNotificationsPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    
    private var deviceToken: String = ""
    private var channel: FlutterMethodChannel?
    private var pushOnState = PushOnState.onMessage
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "push_notifications", binaryMessenger: registrar.messenger())
        let instance = SwiftPushNotificationsPlugin(channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method: String = call.method
        if (method == "getPushToken") {
            result(deviceToken)
        } else {
            result(FlutterMethodNotImplemented);
        }
  }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        if let options = launchOptions as? [String: AnyObject] {
            if let notificationOptions = options[UIApplication.LaunchOptionsKey.remoteNotification.rawValue] as? [String: AnyObject] {
                let notification = notificationOptions
                let aps = notification["aps"] as? [String: AnyObject]
                pushOnState = PushOnState.onLaunch
                receivedRemoteNofitication(data: aps ?? [:])
                pushOnState = PushOnState.onMessage
            }
        }
        getNotificationSettings()
        return true
    }
    
    private func receivedRemoteNofitication(data: [String: Any]) {
        switch pushOnState {
        case .onLaunch:
            print("onLaunch \(data)")
            channel?.invokeMethod("onLaunch", arguments: data)
            break
        case .onResume:
            print("onResume \(data)")
            channel?.invokeMethod("onResume", arguments: data)
            break
        case .onMessage:
            print("onMessage \(data)")
            channel?.invokeMethod("onMessage", arguments: data)
            break
        }
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        pushOnState = PushOnState.onResume
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        pushOnState = PushOnState.onMessage
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data as CVarArg)
        }
        let token = tokenParts.joined()
        self.deviceToken = token
        channel?.invokeMethod("onPushToken", arguments: self.deviceToken)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        print("didRegisterForRemoteNotificationsWithDeviceToken \(token)")
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        guard (userInfo["aps"] as? [String: AnyObject]) != nil else {
            completionHandler(.failed)
            return false
        }
        let aps = userInfo["aps"] as? [String: AnyObject]
        receivedRemoteNofitication(data: aps ?? [:])
        return true
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("getNotificationSettings \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
}
