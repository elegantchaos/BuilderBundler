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
    
    func bundle(target: String, buildProductsPath: String) throws {
        if let root = process.environment["PWD"] {
            let rootURL = URL(fileURLWithPath: root)
            let bundleURL = rootURL.appendingPathComponent("Sources").appendingPathComponent(target).appendingPathComponent("Resources").appendingPathComponent("Bundle")
            let buildProductsURL = rootURL.appendingPathComponent(".build").appendingPathComponent(buildProductsPath)
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
}

if CommandLine.argc > 2 {
    let target = CommandLine.arguments[1]
    let buildProductsPath = CommandLine.arguments[2]
    let bundler = Bundler()
    try bundler.bundle(target: target, buildProductsPath: buildProductsPath)
}
