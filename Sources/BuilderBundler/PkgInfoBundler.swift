// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Bundler which creates a PkgInfo file.
 
 It uses the product kind to decide what to put in the file.
 */

class PkgInfoBundler: ItemBundler {
    override func bundle() {
        let kind = bundler.kind == "executable" ? "APPL" : "BNDL"
        let info = "\(kind)????"
        let url = destination.deletingLastPathComponent().appendingPathComponent("PkgInfo")
        if let data = info.data(using: String.Encoding.utf8) {
            do {
                try data.write(to: url)
            } catch {
                bundler.failed(error: error)
            }
        }
    }
}
