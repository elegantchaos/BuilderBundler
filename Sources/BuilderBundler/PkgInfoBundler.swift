// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class PkgInfoBundler: ItemBundler {
    override func bundle() {
        let kind = bundler.kind == "executable" ? "APPL" : "BNDL"
        let info = "\(kind)????"
        if let data = info.data(using: String.Encoding.utf8) {
            do {
                try data.write(to: destination)
            } catch {
                bundler.failed(error: error)
            }
        }
    }
}
