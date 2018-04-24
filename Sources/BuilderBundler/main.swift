// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 23/04/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

// TODO: copy standard bundled frameworks
// TODO: substitutions in Info.plist
// TODO: generate PkgInfo?

let process = ProcessInfo.processInfo

extension URL {
    func existsLocally() -> Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
}

class Bundler: NSObject, FileManagerDelegate {
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
        print("plist \(plist) path:\(destination)")
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: destination)
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
                case "plist" :
                    try copyDynamic(plist:items, target: target, destination: subpath)
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

    func bundle(target: String, buildProductsPath: String) throws {
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

if CommandLine.argc > 2 {
    let target = CommandLine.arguments[1]
    let buildProductsPath = CommandLine.arguments[2]
    let bundler = Bundler()
    try bundler.bundle(target: target, buildProductsPath: buildProductsPath)
}
