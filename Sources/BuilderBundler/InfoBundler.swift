// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class InfoBundler: ItemBundler {
    var values: [String:Any] = [:]

    func addKeys() {
        values["CFBundleInfoDictionaryVersion"] = "6.0"
        values["CFBundleName"] = bundler.product
    }
    
    func addIfInEnvironment(key: String, infoKey: String) {
        if let value = bundler.environment[key] {
            values[infoKey] = value
        }
    }

    override func bundle() {
        if let info = info as? [String:Any] {
            self.values = info
            addKeys()
            
            do {
                let data = try PropertyListSerialization.data(fromPropertyList: values, format: .xml, options: 0)
                try data.write(to: destination)
            } catch {
                bundler.failed(error: error)
            }
        }
    }
}



/*
 "BuildMachineOSBuild" : "16G1212",
 "DTCompiler": "com.apple.compilers.llvm.clang.1_0",
 "DTPlatformBuild": "9C40b",
 "DTPlatformVersion": "GM",
 "DTSDKBuild": "17C76",
 "DTSDKName": "macosx10.13",
 "DTXcode": "0920",
 "DTXcodeBuild": "9C40b",
 "NSHumanReadableCopyright": "Copyright © 2018 Elegant Chaos. All rights reserved.",
 "NSMainStoryboardFile": "Main",
 
 */
