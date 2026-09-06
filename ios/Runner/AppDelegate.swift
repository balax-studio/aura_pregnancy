import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let galleryChannel = FlutterMethodChannel(
        name: "com.balaxstudio.aura/gallery",
        binaryMessenger: controller.binaryMessenger
      )
      galleryChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "saveImageToGallery" {
          guard let args = call.arguments as? [String: Any],
                let data = (args["imageBytes"] as? FlutterStandardTypedData)?.data,
                let image = UIImage(data: data) else {
            result(FlutterError(code: "INVALID_DATA", message: "Görsel verisi çözümlenemedi", details: nil))
            return
          }

          let saver = ImageSaver { success, error in
            if success {
              result(true)
            } else {
              result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription ?? "Fotoğraf albümüne kaydedilemedi", details: nil))
            }
          }
          saver.save(image)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

private class ImageSaver: NSObject {
  private var onComplete: ((Bool, Error?) -> Void)?
  private var selfRetain: ImageSaver?

  init(onComplete: @escaping (Bool, Error?) -> Void) {
    self.onComplete = onComplete
    super.init()
    self.selfRetain = self
  }

  func save(_ image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    onComplete?(error == nil, error)
    selfRetain = nil
  }
}
