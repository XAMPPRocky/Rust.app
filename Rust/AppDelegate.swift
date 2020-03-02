//
//  AppDelegate.swift
//  Rust
//
//  Created by Erin Power on 08/02/2020.
//  Copyright © 2020 Rust. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        createLogo()
        createMenu()
    }

    func createLogo() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(named: NSImage.Name("status-logo"))
        guard let logo = NSImage(named: NSImage.Name("status-logo")) else { return }

        let resizedLogo = NSImage(size: NSSize(width: 22, height: 22), flipped: false) { (dstRect) -> Bool in
            logo.draw(in: dstRect)
            return true
        }
        //button.action = #selector(printQuote(_:))
        button.image = resizedLogo
    }

    func createMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Stable", action: nil, keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Beta", action: nil, keyEquivalent: "b"))
        menu.addItem(NSMenuItem(title: "Nightly", action: nil, keyEquivalent: "n"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func showPreferences() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "preferencesWindow") as! NSWindowController
        controller.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

