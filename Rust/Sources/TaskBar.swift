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

        print(Rustup.channel().slug)

        let documentation = createMenuItem(title: "Documentation", action: nil, key: "", target: self)
        documentation.submenu = createDocumentationMenu()

        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(TaskBar.showPreferences), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(documentation)
        menu.addItem(NSMenuItem.separator())
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
        menu.addItem(NSMenuItem.separator())
        menu.addItem(createMenuItem(title: "std", action: #selector(openStd), key: "", target: self))
        menu.addItem(createMenuItem(title: "alloc", action: #selector(openAlloc), key: "", target: self))
        menu.addItem(createMenuItem(title: "core", action: #selector(openCore), key: "", target: self))
        menu.addItem(createMenuItem(title: "proc_macro", action: #selector(openProcMacro), key: "", target: self))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Books", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(createMenuItem(title: "Rust Programming Language", action: #selector(openBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "Cargo", action: #selector(openCargoBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "Editions", action: #selector(openEditionBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "Embedded Rust", action: #selector(openEmbeddedBook), key: "", target: self))
        menu.addItem(createMenuItem(title: "Nomicon", action: #selector(openNomicon), key: "", target: self))
        menu.addItem(createMenuItem(title: "Reference", action: #selector(openReference), key: "", target: self))
        menu.addItem(createMenuItem(title: "Rust By Example", action: #selector(openRustByExample), key: "", target: self))
        menu.addItem(createMenuItem(title: "Rustdoc", action: #selector(openRustdoc), key: "", target: self))
        menu.addItem(createMenuItem(title: "Rustc", action: #selector(openRustcBook), key: "", target: self))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Unstable", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(createMenuItem(title: "Testing Framework", action: #selector(openTestDoc), key: "", target: self))
        menu.addItem(createMenuItem(title: "Nightly Features", action: #selector(openUnstableBook), key: "", target: self))
        menu.addItem(NSMenuItem.separator())

        return menu
    }

    @objc func openAlloc() { openDoc("alloc") }
    @objc func openBook() { openDoc("book") }
    @objc func openCargoBook() { openDoc("cargo") }
    @objc func openCore() { openDoc("core") }
    @objc func openEditionBook() { openDoc("edition-guide") }
    @objc func openEmbeddedBook() { openDoc("embedded-book") }
    @objc func openNomicon() { openDoc("nomicon") }
    @objc func openProcMacro() { openDoc("proc_macro") }
    @objc func openReference() { openDoc("reference") }
    @objc func openRustByExample() { openDoc("rust-by-example") }
    @objc func openRustcBook() { openDoc("rustc") }
    @objc func openRustdoc() { openDoc("rustdoc") }
    @objc func openStd() { openDoc("std") }
    @objc func openTestDoc() { openDoc("test") }
    @objc func openUnstableBook() { openDoc("unstable-book") }

    @objc func openDoc(_ resource: String) {
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

    @objc static func showPreferences() {
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
