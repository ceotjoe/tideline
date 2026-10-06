import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeSupportDirectoryFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// The database is a plain file (ADR 0034), so keep it out of iCloud and iTunes backups.
  /// path_provider's application support directory is where Tideline keeps it.
  private func excludeSupportDirectoryFromBackup() {
    let manager = FileManager.default
    guard var url = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      return
    }
    try? manager.createDirectory(at: url, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? url.setResourceValues(values)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
