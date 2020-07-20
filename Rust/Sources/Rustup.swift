import Foundation
import Toml

// MARK: Rustup
class Rustup {
    
    static func output(_ channel: ToolchainChannel?, _ args: [String], callback: @escaping (String) -> ()) {
        Process.outputRustup(nil, channel, args, callback: callback)
    }
    
    static func output(_ args: [String], callback: @escaping (String) -> ()) {
        Process.outputRustup(nil, nil, args, callback: callback)
    }

    static func initialise() throws {
        Process.outputRustup("rustup-init", nil, ["-y", "--no-modify-path"]) {
            _ in
        }
    }
    
    static func getSettings() throws -> Toml? {
        return try? Toml(withString: String(contentsOf: try appDir().appendingPathComponent("settings.toml")))
    }
    
    // MARK: Channel

    /// Returns the currently set channel from rustup.
    static func channel() -> ToolchainChannel {
        let settings = try! getSettings()
        let value = settings?.string("default_toolchain") ?? Rustc.version()

        if value.contains(ToolchainChannel.beta.slug) {
            return .beta
        } else if value.contains(ToolchainChannel.nightly.slug) {
            return .nightly
        } else {
            return .stable
        }
    }

    static func set(channel: ToolchainChannel) {
        Rustup.output(channel, ["default", "\(channel.slug)"]) { _ in }
    }

    // MARK: Target

    struct Target {
        let name: String;
        let installed: Bool;
    }

    static func targets(_ callback: @escaping ([Target]) -> ()) {
        return Rustup.targets(nil, callback)
    }

    static func targets(_ channel: ToolchainChannel?, _ callback: @escaping ([Target]) -> ()) {
        Rustup.output(channel, ["target", "list"]) {
            output in
            
            var targets: [Target] = []

            for line in output.components(separatedBy: .newlines) {
                let array = line.components(separatedBy: .whitespaces)
                targets.append(Target(name: array[0], installed: array.count == 2))
            }

            callback(targets)
        }
    }

    static func installedTargets(_ callback: @escaping ([Target]) -> ()) {
        Rustup.targets({ callback($0.filter({ $0.installed })) })
    }

    static func installedTargets(_ channel: ToolchainChannel?, _ callback: @escaping ([Target]) -> ()) {
        Rustup.targets(channel, { callback($0.filter({ $0.installed })) })
    }

    // MARK: Documentation
    static func documentationDirectory() -> URL {
        var url: URL = URL(string: "")!
        
        DispatchQueue.global().sync {
            Rustup.output(["doc", "--std", "--path"]) {
                url = URL(fileURLWithPath: $0).deletingLastPathComponent()
            }
        }
        
        return url
    }

}

// MARK: Rustc
class Rustc {
    static func output(_ channel: ToolchainChannel?, _ args: [String], callback: @escaping (String) -> ()) {
        Process.outputRustup("rustc", channel, args, callback: callback)
    }
    
    static func output(_ args: [String], callback: @escaping (String) -> ()) {
        output(nil, args, callback: callback)
    }
    
    static func syncOutput(_ channel: ToolchainChannel?, _ args: [String]) throws -> String {
        return try Process.syncRustup("rustc", channel, args)
    }
    
    static func syncOutput(_ args: [String]) throws -> String {
        return try syncOutput(nil, args)
    }

    // MARK: Version
    /// Get current version number from the environment
    static func version() -> String {
        return version(nil)
    }
    /// Return the current version of a specific toolchain, or using the currently set toolchain if `nil`.
    static func version(_ channel: ToolchainChannel?) -> String {
        let output = try! Rustc.syncOutput(channel, ["-V"])
        let regex = try! NSRegularExpression.init(pattern: "(\\d+.\\d+.\\d+)", options: [])
        let match = regex.firstMatch(in: output, options: [], range: .init(location: 0, length: output.lengthOfBytes(using: .utf8)))!

        return (output as NSString).substring(with: match.range(at: 0))
    }
}

// MARK: URL Location Functions
let RUSTUP_DIR = ".rustup"
let CARGO_DIR = ".cargo"

func rustupUrl() -> URL {
    return Bundle.main.url(forResource: "rustup", withExtension: nil)!
}

func rustcUrl() throws -> URL {
    return try appDir()
        .appendingPathComponent(CARGO_DIR, isDirectory: true)
        .appendingPathComponent("bin", isDirectory: true)
        .appendingPathComponent("rustc", isDirectory: false)
}

func appDir() throws -> URL {
    return try FileManager().url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

func rustupHome() throws -> URL {
    try appDir().appendingPathComponent(".rustup", isDirectory: true)
}

func cargoHome() throws -> URL {
    try appDir().appendingPathComponent(".cargo", isDirectory: true)
}
