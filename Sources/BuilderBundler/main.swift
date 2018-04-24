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

if CommandLine.argc > 4 {
    let arguments = CommandLine.arguments
    if let root = process.environment["PWD"] {
        let rootURL = URL(fileURLWithPath: root)
        let bundler = Bundler(product: arguments[1], kind: arguments[4], configuration: arguments[2], platform: arguments[3], root: rootURL)
        bundler.bundle()
    }
}
