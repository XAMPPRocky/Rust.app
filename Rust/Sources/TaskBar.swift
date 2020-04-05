//
//  TaskBar.swift
//  Rust
//
//  Created by Erin Power on 05/04/2020.
//  Copyright © 2020 Rust. All rights reserved.
//

import Cocoa
import Toml

func createMenuItem(title: String, action: Selector?, key charCode: String, target: AnyObject?) -> NSMenuItem {
    let menu = NSMenuItem(title: title, action: action, keyEquivalent: charCode)
    menu.target = target
    return menu
}

class TaskBar {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    init() {
        createLogo()
        createMainMenu()
    }

    func createLogo() {
        let logo = NSImage(named: NSImage.Name("status-logo"))!

        let resizedLogo = NSImage(size: NSSize(width: 22, height: 22), flipped: false) { (dstRect) -> Bool in
            logo.draw(in: dstRect)
            return true
        }

        statusItem.button!.image = resizedLogo
    }
    
    // MARK: Main Menu
    func createMainMenu() {
        let menu = NSMenu()

        let stable = ToolchainMenuItem(channel: .stable, action: #selector(setToolchainStable), key: "s", target: self)

        let beta = ToolchainMenuItem(channel: .beta, action: #selector(setToolchainBeta), key: "b", target: self)
        let nightly = ToolchainMenuItem(channel: .nightly, action: #selector(setToolchainNightly), key: "n", target: self)

        switch Rustup.channel() {
        case .stable:
            stable.state = .on
        case .beta:
            beta.state = .on
        case .nightly:
            nightly.state = .on
        }

        let documentation = createMenuItem(title: "Documentation", action: nil, key: "", target: self)
        documentation.submenu = createDocumentationMenu()

        menu.addItem(createMenuItem(title: "Preferences", action: #selector(showPreferences), key: "p", target: self))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(documentation)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Channel", action: nil, keyEquivalent: ""))
        menu.addItem(stable)
        menu.addItem(beta)
        menu.addItem(nightly)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Targets", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    // MARK: Documentation Menu
    func createDocumentationMenu() -> NSMenu {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "API Docs", action: nil, keyEquivalent: ""))
        menu.addItem(createMenuItem(title: "std", action: #selector(openStd), key: "", target: self))
        menu.addItem(createMenuItem(title: "alloc", action: #selector(openAlloc), key: "", target: self))
        menu.addItem(createMenuItem(title: "core", action: #selector(openCore), key: "", target: self))
        menu.addItem(createMenuItem(title: "proc_macro", action: #selector(openProcMacro), key: "", target: self))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Books", action: nil, keyEquivalent: ""))
        menu.addItem(createMenuItem(title: "Cargo", action: #selector(openCargoBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "Edition Guide", action: #selector(openEditionBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "Embedded Rust", action: #selector(openEmbeddedBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "Nomicon", action: #selector(openNomicon), key: "", target: self))
        menu.addItem(createMenuItem(title: "Reference", action: #selector(openReference), key: "", target: self))
        menu.addItem(createMenuItem(title: "Rust By Example", action: #selector(openRustByExample), key: "", target: self))
        menu.addItem(createMenuItem(title: "Rustdoc Guide", action: #selector(openRustdoc), key: "", target: self))
        menu.addItem(createMenuItem(title: "Rustc Guide", action: #selector(openRustcBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "The Rust Programming Language", action: #selector(openBook), key: "", target: self))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Unstable", action: nil, keyEquivalent: ""))
        menu.addItem(createMenuItem(title: "Testing Framework", action: #selector(openTestDoc), key: "", target: self))
        menu.addItem(createMenuItem(title: "Nightly Features", action: #selector(openUnstableBook), key: "", target: self))
        menu.addItem(NSMenuItem.separator())

        return menu
    }

    @objc func openAlloc() { openDoc("alloc", "https://doc.rust-lang.org/alloc") }
    @objc func openBook() { openDoc("book", "https://doc.rust-lang.org/book") }
    @objc func openCargoBook() { openDoc("cargo", "https://doc.rust-lang.org/cargo") }
    @objc func openCore() { openDoc("core", "https://doc.rust-lang.org/core") }
    @objc func openEditionBook() { openDoc("edition-guide", "https://doc.rust-lang.org/edition-guide") }
    @objc func openEmbeddedBook() { openDoc("embedded-book", "https://doc.rust-lang.org/embedded-book") }
    @objc func openNomicon() { openDoc("nomicon", "https://doc.rust-lang.org/nomicon") }
    @objc func openProcMacro() { openDoc("proc_macro", "https://doc.rust-lang.org/proc_macro") }
    @objc func openReference() { openDoc("reference", "https://doc.rust-lang.org/reference") }
    @objc func openRustByExample() { openDoc("rust-by-example", "https://doc.rust-lang.org/rust-by-example") }
    @objc func openRustcBook() { openDoc("rustc", "https://doc.rust-lang.org/rustc") }
    @objc func openRustdoc() { openDoc("rustdoc", "https://doc.rust-lang.org/rustdoc") }
    @objc func openStd() { openDoc("std", "https://doc.rust-lang.org/std") }
    @objc func openTestDoc() { openDoc("test", "https://doc.rust-lang.org/proc_macro") }
    @objc func openUnstableBook() { openDoc("unstable-book", "https://doc.rust-lang.org/unstable-book") }

    @objc func openDoc(_ resource: String, _ url: String) {
        try! Rustup.run(args: ["doc", "--\(resource)"])
    }

    // MARK: Channel Setters
    @objc func setToolchainStable() { setToolchainChannel(.stable) }
    @objc func setToolchainBeta() { setToolchainChannel(.beta) }
    @objc func setToolchainNightly() { setToolchainChannel(.nightly) }

    @objc func setToolchainChannel(_ channel: ToolchainChannel) {
        Rustup.set(channel: channel)
        resetChannelState()
        statusItem.menu?.item(withTag: channel.menuTag)?.state = .on
    }

    func resetChannelState() {
        for channel in ToolchainChannel.all {
            statusItem.menu?.item(withTag: channel.menuTag)?.state = .off
        }
    }

    @objc func showPreferences() {
        if let window = AppDelegate.preferencesWindow {
            window.showWindow(self)
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        AppDelegate.preferencesWindow = (storyboard.instantiateController(withIdentifier: "preferencesWindow") as! NSWindowController)
        AppDelegate.preferencesWindow?.window?.title = "Rust"
        AppDelegate.preferencesWindow?.window?.center()
        AppDelegate.preferencesWindow?.window?.collectionBehavior = .moveToActiveSpace
        AppDelegate.preferencesWindow!.window?.makeKeyAndOrderFront(nil)
        AppDelegate.preferencesWindow?.window?.orderFrontRegardless()

        AppDelegate.preferencesWindow!.showWindow(self)
    }
}
