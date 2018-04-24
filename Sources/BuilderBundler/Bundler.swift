// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class ItemBundler {
    var info: Any
    let destination: URL
    let bundler: Bundler
    
    required init(info: Any, destination: URL, bundler: Bundler) {
        self.info = info
        self.destination = destination
        self.bundler = bundler
    }
    
    func bundle() {
    }
}

class FolderBundler: ItemBundler {
    override func bundle() {
        if let items = info as? [String:Any] {
            do {
                try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
            } catch {
                bundler.failed(error: error)
            }
            
            for item in items {
                let subpath = destination.appendingPathComponent(item.key)
                if let bundlerClass = bundler.bundlerClass(for: item.value, name: item.key) {
                    let itemBundler = bundlerClass.init(info: item, destination: subpath, bundler: bundler)
                    itemBundler.bundle()
                }
            }
        }
    }
}

class InfoBundler: ItemBundler {
    override func bundle() {
        if var info = info as? [String:Any] {
            info["CFBundleInfoDictionaryVersion"] = "6.0"
            info["CFBundleName"] = bundler.product
            
            do {
                let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
                try data.write(to: destination)
            } catch {
                bundler.failed(error: error)
            }
        }
    }
}

class ApplicationInfoBundler: InfoBundler {
    override func bundle() {
        if var info = info as? [String:Any] {
            info["CFBundleInfoDictionaryVersion"] = "6.0"
            info["CFBundleName"] = bundler.product
            self.info = info
            super.bundle()
        }
    }
}

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
    
    func failed(error: Error) {
        
        
    }
    
    func bundlerClass(for item: Any, name: String) -> ItemBundler.Type? {
        switch (name as NSString).pathExtension {
        case "":
            if name.last == "/" {
                return FolderBundler.self
            }
            
        case "plist":
            return kind == "executable" ? ApplicationInfoBundler.self : InfoBundler.self
            
        default:
            return nil
        }
        
        return nil
    }
    
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
    
    func copyStatic(resourcesURL: URL, destination: URL) throws {
        let bundleURL = resourcesURL.appendingPathComponent("Bundle")
        if bundleURL.existsLocally() {
            let binaryURL = destination.appendingPathComponent(product)
            let fm = FileManager()
            fm.delegate = self
            if fm.fileExists(atPath: bundleURL.path) {
                print("Bundling \(bundleURL).")
                let appBundleURL = destination.appendingPathComponent(product, isDirectory:false).appendingPathExtension("app")
                try fm.createDirectory(at: appBundleURL, withIntermediateDirectories: true, attributes: nil)
                try fm.copyItem(at: bundleURL, to: appBundleURL)
                
                if let binaryDst = binaryDst {
                    let binaryDestURL = binaryDst.appendingPathComponent(product)
                    try fm.copyItem(at: binaryURL, to: binaryDestURL)
                }
            } else {
                print("Missing bundle: \(product)")
            }
        }
    }
    
    func copyDynamic(plist: [String:Any], destination: URL) throws {
        var info = plist
        info["CFBundleInfoDictionaryVersion"] = "6.0"
        info["CFBundleName"] = product
        
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
    
    func copyDynamic(application plist: [String:Any], destination: URL) throws {
        var info = plist
        info["CFBundlePackageType"] = "APPL"
        info["CFBundleExecutable"] = product
        info["NSPrincipalClass"] = "NSApplication"
        
        try copyDynamic(plist: info, destination: destination)
    }
    
    func copyDynamic(item: Any, destination: URL) throws {
        print("copy \(item) path:\(destination)")
    }
    
    
    func copyDynamic(resourcesURL: URL, destination: URL) throws {
        let bundleSpecURL = resourcesURL.appendingPathComponent("Bundle.json")
        let data = try Data(contentsOf: bundleSpecURL)
        if let spec = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
            if let items = spec["items"] as? [String:Any] {
                let bundler = FolderBundler(info: items, destination: destination, bundler: self)
                bundler.bundle()
            }
        }
    }
    
    func bundleURL(buildProductsURL: URL) -> URL {
        let productURL = buildProductsURL.appendingPathComponent(product, isDirectory:false)
        
        switch kind {
        case "executable":
            return productURL.appendingPathExtension("app")
        case "library":
            return productURL.appendingPathExtension("framework")
        default:
            return productURL.appendingPathExtension("bundle")
        }
    }
    
    func bundle() throws {
        let buildProductsPath = "\(platform)/\(configuration)"
        if let root = process.environment["PWD"] {
            let rootURL = URL(fileURLWithPath: root)
            let resourcesURL = rootURL.appendingPathComponent("Sources").appendingPathComponent(product).appendingPathComponent("Resources")
            let buildProductsURL = rootURL.appendingPathComponent(".build").appendingPathComponent(buildProductsPath)
            let destination = bundleURL(buildProductsURL: buildProductsURL)
            try copyStatic(resourcesURL: resourcesURL, destination: destination)
            try copyDynamic(resourcesURL: resourcesURL, destination: destination)
        }
    }
}
