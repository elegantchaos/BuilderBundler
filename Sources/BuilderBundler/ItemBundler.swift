// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Abstract class responsible for copying an item into the bundle.
 
 Intended to be subclassed.
 */

class ItemBundler {
    var info: Any
    let destination: URL
    let source: URL
    let bundler: Bundler
    
    required init(info: Any, source: URL, destination: URL, bundler: Bundler) {
        self.info = info
        self.source = source
        self.destination = destination
        self.bundler = bundler
    }
    
    func bundle() {
    }
}
