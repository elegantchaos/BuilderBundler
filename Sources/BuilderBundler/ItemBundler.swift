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
