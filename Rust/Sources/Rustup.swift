//
//  Rustc.swift
//  Rust
//
//  Created by Erin Power on 09/03/2020.
//  Copyright © 2020 Rust. All rights reserved.
//

import Foundation
import Toml

class Rustup {
    static func run(args: [String]) throws {
        let process = Process()
        process.executableURL = rustupUrl()
        process.arguments = args
        try process.run()
    }

    static func output(args: [String]) throws -> String {
        let stdOut = Pipe()
        let process = Process()
        process.executableURL = rustcUrl()
        process.arguments = args
        process.standardOutput = stdOut
        try process.run()

        return String(data: stdOut.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
    }

    fileprivate static func getSettings() throws -> Toml {
        return try Toml(contentsOfFile: "/Users/ep/.rustup/settings.toml")
    }
    
    static func channel() -> ToolchainChannel {
        let settings = try! getSettings()
        let value = settings.string("default_toolchain") ?? version()

        if value.contains(ToolchainChannel.beta.slug) {
            return .beta
        } else if value.contains(ToolchainChannel.nightly.slug) {
            return .nightly
        } else {
            return .stable
        }
    }
    
    /// Get current version number from the environment
    static func version() -> String {
        return version(nil)
    }
    
    /// Return the current version of a specific toolchain, or using the currently set toolchain if `nil`.
    static func version(_ channel: ToolchainChannel?) -> String {
        let args = (channel != nil) ? ["+\(channel!.slug)", "-V"] : ["-V"]
        let output = try! Rustup.output(args: args)
        let regex = try! NSRegularExpression.init(pattern: "(\\d+.\\d+.\\d+)", options: [])

        let match = regex.firstMatch(in: output, options: [], range: .init(location: 0, length: output.lengthOfBytes(using: .utf8)))!

        return (output as NSString).substring(with: match.range(at: 0))
    }
}

func rustupUrl() -> URL {
    return URL(string: "file:///Users/ep/.cargo/bin/rustup")!
}

func rustcUrl() -> URL {
    return URL(string: "file:///Users/ep/.cargo/bin/rustc")!
}
