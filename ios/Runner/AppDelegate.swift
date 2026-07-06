import Flutter
import UIKit
import flutter_downloader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}

extension AppDelegate{
    
    func downloadImageFromApi(url: String, fileName: String) {
//        guard let url = URL(string: url) else { return }
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileURL = documentsDirectory.appendingPathComponent("\(fileName).jpg")
//
//            do {
//                try data.write(to: fileURL)
//                print("Image saved to: \(fileURL)")
//            } catch {
//                print("Error saving image: \(error)")
//            }
//        }
//        task.resume()
    }
    
    func checkFile()->Bool{
        return getImage(fileName: "example1") != nil && getImage(fileName: "example2") != nil && getImage(fileName: "example3") != nil
    }
    
    func getImage(fileName: String)->UIImage?{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("\(fileName).jpg")
        if let image = UIImage(contentsOfFile: fileURL.path) {
            return image
        } else {
            return nil
        }
    }
    
    func getPath(fileName: String)->String?{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("\(fileName).jpg")
        return fileURL.path
    }
    
    func clearSample(result: @escaping FlutterResult){
        let examples: [String] = ["example1", "example2", "example3"]
        for example in examples{
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(example).jpg")
            if (FileManager.default.fileExists(atPath: fileURL.path)){
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("Success deleting image:", example)
                } catch {
                    print("Error deleting image:", error)
                }
            }else{
                print("image \(example).jpg not found")
            }
        }
        result(true)
    }
    
}

