// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


class Bundler: NSObject, FileManagerDelegate {
    let product: String
    let kind: String
    let configuration: String
    let platform: String

    init(product: String, kind: String, configuration: String, platform: String) {
        self.product = product
        self.kind = kind
        self.configuration = configuration
        self.platform = platform
    }
    
    var binaryDst: URL? = nil
    
    func fileManager(_ fileManager: FileManager, shouldCopyItemAt srcURL: URL, to dstURL: URL) -> Bool {
        if dstURL.lastPathComponent == "MacOS" {
            binaryDst = dstURL
        }
        
        return true
    }
    
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        let nserr = error as NSError
        if (nserr.domain == NSCocoaErrorDomain) && (nserr.code == NSFileWriteFileExistsError) {
            return true
        }
        return false
    }
    
    func copyStatic(target: String, resourcesURL: URL, buildProductsURL: URL) throws {
        let bundleURL = resourcesURL.appendingPathComponent("Bundle")
        if bundleURL.existsLocally() {
            let binaryURL = buildProductsURL.appendingPathComponent(target)
            let fm = FileManager()
            fm.delegate = self
            if fm.fileExists(atPath: bundleURL.path) {
                print("Bundling \(bundleURL).")
                let appBundleURL = buildProductsURL.appendingPathComponent(target, isDirectory:false).appendingPathExtension("app")
                try fm.createDirectory(at: appBundleURL, withIntermediateDirectories: true, attributes: nil)
                try fm.copyItem(at: bundleURL, to: appBundleURL)
                
                if let binaryDst = binaryDst {
                    let binaryDestURL = binaryDst.appendingPathComponent(target)
                    try fm.copyItem(at: binaryURL, to: binaryDestURL)
                }
            } else {
                print("Missing bundle: \(target)")
            }
        }
    }
    
    func copyDynamic(plist: [String:Any], target: String, destination: URL) throws {
        var info = plist
        info["CFBundleInfoDictionaryVersion"] = "6.0"
        info["CFBundleName"] = target
        
        let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        try data.write(to: destination)
    }
    
    /*
     "BuildMachineOSBuild" : "16G1212",
     "CFBundleIdentifier": "com.elegantchaos.BuilderExampleApp",
     "CFBundleShortVersionString": "1.0",
     "CFBundleSupportedPlatforms": ["MacOSX"],
     "CFBundleVersion": "1",
     "DTCompiler": "com.apple.compilers.llvm.clang.1_0",
     "DTPlatformBuild": "9C40b",
     "DTPlatformVersion": "GM",
     "DTSDKBuild": "17C76",
     "DTSDKName": "macosx10.13",
     "DTXcode": "0920",
     "DTXcodeBuild": "9C40b",
     "LSMinimumSystemVersion": "10.12",
     "NSHumanReadableCopyright": "Copyright © 2018 Elegant Chaos. All rights reserved.",
     "NSMainStoryboardFile": "Main",
     
     */
    
    func copyDynamic(application plist: [String:Any], target: String, destination: URL) throws {
        var info = plist
        info["CFBundlePackageType"] = "APPL"
        info["CFBundleExecutable"] = target
        info["NSPrincipalClass"] = "NSApplication"
        
        try copyDynamic(plist: info, target: target, destination: destination)
    }
    
    func copyDynamic(item: Any, target: String, destination: URL) throws {
        print("copy \(item) path:\(destination)")
    }
    
    func copyDynamic(items: [String:Any], target: String, destination: URL) throws {
        do {
            try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        for item in items {
            let subpath = destination.appendingPathComponent(item.key)
            if var items = item.value as? [String:Any] {
                let type = items["type"] as? String ?? "folder"
                items.removeValue(forKey: "type")
                switch type {
                case "plist" : try copyDynamic(plist:items, target: target, destination: subpath)
                case "application-plist" : try copyDynamic(application: items, target: target, destination: destination)
                default:
                    try copyDynamic(items: items, target: target, destination: subpath)
                }
            } else {
                try copyDynamic(item: item.value, target: target, destination: subpath)
            }
        }
    }
    
    func copyDynamic(target: String, resourcesURL: URL, buildProductsURL: URL) throws {
        let bundleSpecURL = resourcesURL.appendingPathComponent("Bundle.json")
        let data = try Data(contentsOf: bundleSpecURL)
        if let spec = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
            if let items = spec["items"] as? [String:Any] {
                try copyDynamic(items: items, target: target, destination: buildProductsURL)
            }
        }
    }
    
    func bundle() throws {
        let target = product
        let buildProductsPath = "\(platform)/\(configuration)"
        if let root = process.environment["PWD"] {
            let rootURL = URL(fileURLWithPath: root)
            let resourcesURL = rootURL.appendingPathComponent("Sources").appendingPathComponent(target).appendingPathComponent("Resources")
            let buildProductsURL = rootURL.appendingPathComponent(".build").appendingPathComponent(buildProductsPath)
            let appBundleURL = buildProductsURL.appendingPathComponent(target, isDirectory:false).appendingPathExtension("app")
            //            try copyStatic(target: target, resourcesURL: resourcesURL, buildProductsURL: appBundleURL)
            try copyDynamic(target: target, resourcesURL: resourcesURL, buildProductsURL: appBundleURL)
        }
    }
}
