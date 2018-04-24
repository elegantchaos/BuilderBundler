// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


class BundleInfoBundler: InfoBundler {
    override func addKeys() {
        values["CFBundleInfoDictionaryVersion"] = "6.0"
        values["CFBundleName"] = bundler.product
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
