// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class ExecutableBundler: ItemBundler {
    override func bundle() {
        let binaryName = bundler.product
        let binaryDestination = destination.appendingPathComponent(binaryName)
        let binarySource = bundler.products.appendingPathComponent(binaryName)
        do {
            try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.copyItem(at: binarySource, to: binaryDestination)
        } catch {
            bundler.failed(error: error)
        }
    }
}
