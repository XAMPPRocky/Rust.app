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
    
    // MARK: Run
    static func run(args: [String]) throws {
        try Rustup.run(channel: nil, args: args)
    }
    
    fileprivate static func run(channel: ToolchainChannel?, args: [String]) throws {
        var args = args
        if let channel = channel {
            args.insert("+\(channel.slug)", at: 0)
        }
        
        let process = Process()
        process.executableURL = rustupUrl()
        process.arguments = args
        try process.run()
    }
    
    // MARK: Output
    static func output(args: [String]) throws -> String {
        return try output(channel: nil, args: args)
    }
    
    static func output(channel: ToolchainChannel?, args: [String]) throws -> String {
        var args = args
        if let channel = channel {
            args.insert("+\(channel.slug)", at: 0)
        }
        
        let stdOut = Pipe()
        let process = Process()
        process.executableURL = rustupUrl()
        process.arguments = args
        process.standardOutput = stdOut
        try process.run()
        
        let output = String(data: stdOut.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
        return output
    }

    fileprivate static func getSettings() throws -> Toml {
        return try Toml(contentsOfFile: "/Users/ep/.rustup/settings.toml")
    }

    // MARK: Channel
    
    /// Returns the currently set channel from rustup.
    static func channel() -> ToolchainChannel {
        let settings = try! getSettings()
        let value = settings.string("default_toolchain") ?? Rustc.version()

        if value.contains(ToolchainChannel.beta.slug) {
            return .beta
        } else if value.contains(ToolchainChannel.nightly.slug) {
            return .nightly
        } else {
            return .stable
        }
    }

    static func set(channel: ToolchainChannel) {
        try! Rustup.run(args: ["default", "\(channel.slug)"])
    }
    
    // MARK: Target
    
    struct Target {
        let name: String;
        let installed: Bool;
    }
    
    static func targets() -> [Target] {
        return Rustup.targets(channel: nil)
    }
    
    static func targets(channel: ToolchainChannel?) -> [Target] {
        let output = try! Rustup.output(channel: channel, args: ["target", "list"])
        var targets: [Target] = []
        
        for line in output.components(separatedBy: .newlines) {
            let array = line.components(separatedBy: .whitespaces)
            targets.append(Target(name: array[0], installed: array.count == 2))
        }
        
        return targets
    }
    
    static func installedTargets() -> [Target] {
        return Rustup.targets().filter({$0.installed})
    }
    
    static func installedTargets(channel: ToolchainChannel?) -> [Target] {
        return Rustup.targets(channel: channel).filter({$0.installed})
    }
    
    // MARK: Documentation
    static func documentationDirectory() throws -> URL {
        return try URL(fileURLWithPath: Rustup.output(args: ["doc", "--std", "--path"])).deletingLastPathComponent()
    }
}

// MARK: Rustc
class Rustc {
    // MARK: Run
    static func run(args: [String]) throws {
        try Rustup.run(channel: nil, args: args)
    }
    
    fileprivate static func run(channel: ToolchainChannel?, args: [String]) throws {
        var args = args
        if let channel = channel {
            args.insert("+\(channel.slug)", at: 0)
        }
        
        let process = Process()
        process.executableURL = rustcUrl()
        process.arguments = args
        try process.run()
    }
    
    // MARK: Output
    static func output(args: [String]) throws -> String {
        return try output(channel: nil, args: args)
    }
    
    static func output(channel: ToolchainChannel?, args: [String]) throws -> String {
        var args = args
        if let channel = channel {
            args.insert("+\(channel.slug)", at: 0)
        }
        
        let stdOut = Pipe()
        let process = Process()
        process.executableURL = rustcUrl()
        process.arguments = args
        process.standardOutput = stdOut
        try process.run()
        
        let output = String(data: stdOut.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
        return output
    }
    
    // MARK: Version
    /// Get current version number from the environment
    static func version() -> String {
        return version(nil)
    }
    /// Return the current version of a specific toolchain, or using the currently set toolchain if `nil`.
    static func version(_ channel: ToolchainChannel?) -> String {
        let output = try! Rustup.output(args: ["-V"])
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
