//
//  LaunchController.swift
//  Rust
//
//  Created by Erin Power on 09/03/2020.
//  Copyright © 2020 Rust. All rights reserved.
//

import Cocoa

class LaunchController: NSViewController {

    @IBOutlet weak var subtitle: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        subtitle.stringValue = "Latest Stable Version (\(Rustc.version(.stable)))"
    }
    
}
