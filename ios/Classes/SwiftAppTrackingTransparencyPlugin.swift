import Flutter
import UIKit
import AppTrackingTransparency
import AdSupport

public class SwiftAppTrackingTransparencyPlugin: NSObject, FlutterPlugin {

  var result: Int = -1;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app_tracking_transparency", binaryMessenger: registrar.messenger())
    let instance = SwiftAppTrackingTransparencyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getTrackingAuthorizationStatus") {
        getTrackingAuthorizationStatus(result: result)
    }
    else if (call.method == "requestTrackingAuthorization") {
        requestTrackingAuthorization(result: result)
    }
    else if (call.method == "getAdvertisingIdentifier") {
        getAdvertisingIdentifier(result: result)
    }
    else {
        result(FlutterMethodNotImplemented)
    }
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.requestPermission()
    }
  } 

  func requestPermission() {
    if #available(iOS 15.0, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
				print("Authorized")
				result = 3
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
				result = 2
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
				result = 0
                case .restricted:
                    print("Restricted ")
				result = 1
                @unknown default:
                   result = 0
                }
            })
        }
    }
  }

  private func getTrackingAuthorizationStatus(result: @escaping FlutterResult) {
    if #available(iOS 14, *) {
        result(Int(ATTrackingManager.trackingAuthorizationStatus.rawValue))
    } else {
        // return notSupported
        result(Int(4))
    }
  }

  /*
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
  */
  private func requestTrackingAuthorization(result: @escaping FlutterResult) {

    if #available(iOS 15, *) {
      
      if(result != -1) {
        result(result)
      } else {
        result(Int(4))
      }
    } else {

      if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            result(Int(status.rawValue))
        	}) 
		  } else {
        // return notSupported
        result(Int(4))
    	}

    }

  }

  private func getAdvertisingIdentifier(result: @escaping FlutterResult) {
    result(String(ASIdentifierManager.shared().advertisingIdentifier.uuidString))
  }
}
