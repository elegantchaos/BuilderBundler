// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class InfoBundler: ItemBundler {
    var values: [String:Any] = [:]

    func addKeys() {
    }
    
    func addIfInEnvironment(key: String, infoKey: String) {
        if let value = bundler.environment[key] {
            values[infoKey] = value
        }
    }

    func substituteVariables() {
        if let info = info as? [String:Any] {
            var values = info
            for item in info {
                if var variable = item.value as? String {
                    if variable.first == "$" {
                        variable.removeFirst()
                        if let value = bundler.environment[variable] {
                            values[item.key] = value
                        }
                    }
                }
            }
            self.values = values
        }
    }
        
    override func bundle() {
        substituteVariables()
        addKeys()

        do {
            let data = try PropertyListSerialization.data(fromPropertyList: values, format: .xml, options: 0)
            try data.write(to: destination)
        } catch {
            bundler.failed(error: error)
        }
    }
}
