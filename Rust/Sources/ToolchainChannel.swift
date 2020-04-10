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
            return "Stable (\(Rustc.version(.stable)))"
        case .beta:
            return "Beta"
        case .nightly:
            return "Nightly"
        }
    }
    
    var shortcutKey: String {
        switch self {
        case .stable:
            return "s"
        case .beta:
            return "b"
        case .nightly:
            return "n"
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
