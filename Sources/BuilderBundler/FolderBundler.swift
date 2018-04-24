// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Copies a folder into the bundle.
 
 We get the contents of the folder from two places:
 
 - the source folder (if it exists): this corresponds to a folder in the source directory containing resources to copy.
 - the info dictionary: each item in this is assumed to specify something to copy into the folder, and is processed recursively
   by making a bundler object for it and calling bundle() on it.
 
 */

class FolderBundler: ItemBundler {
    override func bundle() {
        if let items = info as? [String:Any] {
            let fm = bundler.fileManager
            _ = bundler.createDirectory(at: destination)
            
            // process folder items
            if source.existsLocally() {
                try? fm.copyItem(at: source, to: destination)
            }
            
            // process dictionary items
            for item in items {
                let itemDestination = destination.appendingPathComponent(item.key)
                let itemSource = source.appendingPathComponent(item.key)
                let bundlers = bundler.bundlers(for: item.value, name: item.key)
                for bundlerClass in bundlers {
                    let itemBundler = bundlerClass.init(info: item.value, source: itemSource, destination: itemDestination, bundler: bundler)
                    itemBundler.bundle()
                }
            }
        }
    }
}
