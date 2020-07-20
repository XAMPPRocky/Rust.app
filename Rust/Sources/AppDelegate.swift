import Cocoa
import Toml
import AppMover

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static var preferencesWindow: NSWindowController? = nil
    var menu: TaskBar? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if !DEBUG
        AppMover.moveIfNecessary()
        #endif
        try! Rustup.initialise()
        
        self.menu = TaskBar()
        //SpotlightDocumentation.generateDocumentationSpotlight()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

