// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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
