// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class ApplicationInfoBundler: InfoBundler {
    override func addKeys() {
        super.addKeys()
        values["CFBundlePackageType"] = "APPL"
        values["NSPrincipalClass"] = bundler.environment["principal-class", default:"NSApplication"]
        values["NSMainStoryboardFile"] = bundler.environment["main-storyboard", default: "Main"]
        values["CFBundleExecutable"] = bundler.product

        addIfInEnvironment(key: "build", infoKey: "CFBundleVersion")
        addIfInEnvironment(key: "version", infoKey: "CFBundleShortVersionString")
        addIfInEnvironment(key: "identifier", infoKey: "CFBundleIdentifier")
        addIfInEnvironment(key: "platforms", infoKey: "CFBundleSupportedPlatforms")
        addIfInEnvironment(key: "minimum-system", infoKey: "LSMinimumSystemVersion")
    }
}
