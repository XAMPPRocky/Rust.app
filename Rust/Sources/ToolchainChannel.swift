//
//  ToolchainMenuItem.swift
//  Rust
//
//  Created by Erin Power on 02/03/2020.
//  Copyright © 2020 Rust. All rights reserved.
//

import Foundation
import AppKit

@objc enum ToolchainChannel: Int {
    case stable
    case beta
    case nightly
    
    static var all = [ToolchainChannel.stable, .beta, .nightly]
    
    var slug: String {
        switch self {
        case .stable:
            return "stable"
        case .beta:
            return "beta"
        case .nightly:
            return "nightly"
        }
    }
    
    var description: String {
        switch self {
        case .stable:
            return "Stable (\(Rustup.version(.stable)))"
        case .beta:
            return "Beta"
        case .nightly:
            return "Nightly"
        }
    }
    
    var menuTag: Int {
        switch self {
        case .stable:
            return 10
        case .beta:
            return 20
        case .nightly:
            return 30
        }
    }
}

class ToolchainMenuItem: NSMenuItem {
    var channel: ToolchainChannel
    
    init(channel: ToolchainChannel, action selector: Selector?, key charCode: String, target: AnyObject?) {
        self.channel = channel
        super.init(title: self.channel.description, action: selector, keyEquivalent: charCode)
        self.tag = self.channel.menuTag
        self.target = target
    }
    
    convenience init(channel: ToolchainChannel, action selector: Selector?, target: AnyObject?) {
        self.init(channel: channel, action: selector, key: "", target: target)
    }
    
    required init(coder: NSCoder) {
        self.channel = ToolchainChannel(rawValue: Int(coder.decodeInt32(forKey: "channel")))!
        super.init(coder: coder)
    }
}
