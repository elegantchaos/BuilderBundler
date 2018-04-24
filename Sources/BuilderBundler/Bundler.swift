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
    let environment: [String:String]
    let root: URL
    let products: URL
    let fileManager : FileManager
    
    init(product: String, kind: String, configuration: String, platform: String, root: URL) {
        self.product = product
        self.kind = kind
        self.configuration = configuration
        self.platform = platform
        self.environment = ProcessInfo.processInfo.environment
        self.root = root
        self.products = root.appendingPathComponent(".build").appendingPathComponent("\(platform)/\(configuration)")
        self.fileManager = FileManager()
        super.init()
        
        self.fileManager.delegate = self
    }
    
    var binaryDst: URL? = nil
    
    func failed(error: Error) {
        
        
    }
    
    func bundlers(for item: Any, name: String) -> [ItemBundler.Type] {
        var bundlers: [ItemBundler.Type] = []
        switch name {
        case "MacOS":
            bundlers.append(ExecutableBundler.self)
            
        case "Info.plist":
            let bundler = kind == "executable" ? ApplicationInfoBundler.self : BundleInfoBundler.self
            bundlers.append(bundler)
            bundlers.append(PkgInfoBundler.self)
            
        case "Frameworks/":
            bundlers.append(FrameworksBundler.self)
            
        default:
            switch (name as NSString).pathExtension {
            case "":
                if name.last == "/" {
                    bundlers.append(FolderBundler.self)
                }
                
            case "plist":
                bundlers.append(InfoBundler.self)
                
            default:
                break
            }
        }
        
        return bundlers
    }
    
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        let nserr = error as NSError
        if (nserr.domain == NSCocoaErrorDomain) && (nserr.code == NSFileWriteFileExistsError) {
            return true
        }
        return false
    }
    
    func createDirectory(at url: URL) -> Bool {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let error as NSError {
            return (error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)
        } catch {
            return false
        }
    }
    
    func copy(resourcesURL: URL, destination: URL) throws {
        let bundleURL = resourcesURL.appendingPathComponent("Bundle")
        let bundleSpecURL = resourcesURL.appendingPathComponent("Bundle.json")
        let data = try Data(contentsOf: bundleSpecURL)
        if let spec = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
            if let items = spec["items"] as? [String:Any] {
                let bundler = FolderBundler(info: items, source: bundleURL, destination: destination, bundler: self)
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
    
    func bundle() {
        let resourcesURL = root.appendingPathComponent("Sources").appendingPathComponent(product).appendingPathComponent("Resources")
        let destination = bundleURL(buildProductsURL: products)
        do {
            try copy(resourcesURL: resourcesURL, destination: destination)
        }
        catch {
            failed(error: error)
        }
    }
}
