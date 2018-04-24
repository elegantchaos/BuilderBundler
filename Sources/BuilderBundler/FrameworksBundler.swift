// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class FrameworksBundler: ItemBundler {
    let standardFrameworks = [
        "libswiftAppKit",
        "libswiftCore",
        "libswiftCoreData",
        "libswiftCoreFoundation",
        "libswiftCoreGraphics",
        "libswiftCoreImage",
        "libswiftDarwin",
        "libswiftDispatch",
        "libswiftFoundation",
        "libswiftIOKit",
        "libswiftMetal",
        "libswiftObjectiveC",
        "libswiftos",
        "libswiftQuartzCore",
        "libswiftXPC",
    ]
    
    func platformURL() -> URL? {
        let result = Process.run("/usr/bin/xcrun", arguments: ["--show-sdk-platform-path"])
        if result.status == 0 {
            return URL(fileURLWithPath: result.stdout.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            
        }
        return nil
    }
    
    override func bundle() {
        if let items = info as? [String:Any] {
            do {
                try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
            } catch {
                bundler.failed(error: error)
            }
            
            if items["include-standard"] as? Bool == true {
                if let url = platformURL() {
                    let developerURL = url.deletingLastPathComponent().deletingLastPathComponent()
                    let toolchainURL = developerURL.appendingPathComponent("Toolchains").appendingPathComponent("XcodeDefault.xctoolchain")
                    let frameworksURL = toolchainURL.appendingPathComponent("usr/lib/swift/macosx")
                    
                    let fm = FileManager.default
                    for framework in standardFrameworks {
                        let sourceURL = frameworksURL.appendingPathComponent(framework).appendingPathExtension("dylib")
                        let destURL = destination.appendingPathComponent(sourceURL.lastPathComponent)
                        do {
                            try fm.copyItem(at: sourceURL, to: destURL)
                        } catch {
                            bundler.failed(error: error)
                        }
                    }
                }
            }
        }
    }
}
