import Flutter
import UIKit
import UserNotifications

/// `RestartAppPlugin` class provides a method to restart a Flutter application in iOS.
///
/// It uses the Flutter platform channels to communicate with the Flutter code.
/// Specifically, it uses a `FlutterMethodChannel` named 'restart' for this communication.
///
/// The main functionality is provided by the `handle` method.
public class RestartAppPlugin: NSObject, FlutterPlugin {
  /// Registers the plugin with the given `registrar`.
  ///
  /// This function is called when the plugin is registered with Flutter.
  /// It creates a `FlutterMethodChannel` named 'restart', and sets this plugin instance as
  /// the delegate for method calls from Flutter.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "restart", binaryMessenger: registrar.messenger())
    let instance: RestartAppPlugin = RestartAppPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Handles method calls from the Flutter code.
  ///
  /// If the method call is 'restartApp', it requests notification permissions and then sends a
  /// notification. Finally, it exits the app.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "restartApp" {
      self.requestNotificationPermissions { granted in
        if granted {
          self.sendNotification()
        }
        exit(0)
      }
    }
  }

  /// Requests notification permissions.
  ///
  /// This function gets the current notification center and then requests alert notification
  /// permissions. If the permissions are granted, or if there's an error, it calls the given
  /// `completion` handler with the appropriate value.
  private func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
    let current = UNUserNotificationCenter.current()
    current.requestAuthorization(options: [.alert]) { granted, error in
      if let error = error {
        print("Error requesting notification permissions: \(error)")
        completion(false)
      } else {
        completion(granted)
      }
    }
  }

  /// Sends a notification.
  ///
  /// This function sets up the notification content and trigger, creates a notification request,
  /// and then adds the request to the notification center.
  private func sendNotification() {
    var stringBody = "Please tap here to restart the app";
    let preferredLanguage = Locale.preferredLanguages.first

    let arr = preferredLanguage.components(separatedBy: "-")
    let deviceLanguage = arr.first
    if(deviceLanguage == "vi"){
        stringBody = "Vui lòng chạm vào đây để khởi động lại ứng dụng."
    }

    let content = UNMutableNotificationContent()
    content.title = "TVSI Mobile"
    content.body = stringBody
    content.sound = nil

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: "RestartApp", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }
}
