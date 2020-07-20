import Foundation

/// Queue of launched rustup processes.
fileprivate var PROCESS_QUEUE: [Int32: Process] = [:]

fileprivate func launchProcess(tool: String? = "rustup", channel: ToolchainChannel?, args: [String], pipe: Pipe) -> Process {
    let process = Process()
    var args = args
    var environment = ProcessInfo.processInfo.environment

    if let channel = channel {
        args.insert("+\(channel.slug)", at: 0)
    }

    environment["RUSTUP_HOME"] = try! rustupHome().path
    environment["CARGO_HOME"] = try! cargoHome().path
    environment["RUSTUP_FORCE_ARG0"] = tool

    let url: URL!
    switch tool {
    case .some("rustc"):
        url = try! rustcUrl()
        break
    default:
        url = rustupUrl()
    }
    
    process.executableURL = url
    process.environment = environment
    process.arguments = args
    process.standardOutput = pipe
    return process
}

extension Process {
    static func outputRustup(_ tool: String? = "rustup", _ channel: ToolchainChannel?, _ args: [String], callback: @escaping (String) -> ()) {
        DispatchQueue.global().async {
            let pipe = Pipe()
            var bigOutputString: String = ""

            pipe.fileHandleForReading.readabilityHandler = { (fileHandle) -> Void in
                let availableData = fileHandle.availableData
                let newOutput = String.init(data: availableData, encoding: .utf8)
                bigOutputString.append(newOutput!)
                print("\(newOutput!)")
                // Display the new output appropriately in a NSTextView for example

            }

            let process = launchProcess(tool: tool, channel: channel, args: args, pipe: pipe)
            let identifier = process.processIdentifier
            
            process.launch()
            process.waitUntilExit()
            PROCESS_QUEUE[identifier] = process

            DispatchQueue.main.async {
                // End of the Process, give feedback to the user.
                let process = PROCESS_QUEUE.removeValue(forKey: identifier)
                process?.terminate()
                callback(bigOutputString)
            }
        }
    }

    static func syncRustup(_ tool: String? = "rustup", _ channel: ToolchainChannel?, _ args: [String]) throws -> String {
        let pipe = Pipe()
        let process = launchProcess(tool: tool, channel: channel, args: args, pipe: pipe)
        try! process.run()

        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
        return output
    }
}
