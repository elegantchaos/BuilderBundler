// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct ProcessResult {
    let status: Int
    let stdout: String
    let stderr: String
}

extension Process {
    static func run(_ command : String, arguments: [String] = []) -> ProcessResult {
        let pipe = Pipe()
        let handle = pipe.fileHandleForReading
        let errPipe = Pipe()
        let errHandle = errPipe.fileHandleForReading
        
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = errPipe
        //    process.environment = self.environment
        process.launch()
        let data = handle.readDataToEndOfFile()
        let errData = errHandle.readDataToEndOfFile()
        
        process.waitUntilExit()
        let capturedOutput = String(data:data, encoding:String.Encoding.utf8)
        let errorOutput = String(data:errData, encoding:String.Encoding.utf8)
        let status = process.terminationStatus
        return ProcessResult(status: Int(status), stdout: capturedOutput ?? "", stderr: errorOutput ?? "")
    }
}
