import SwiftUI

@main
struct TimeLimeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var eventViewModel: EventViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the event view model
        eventViewModel = EventViewModel()

        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            // Use SF Symbol for lime/calendar icon
            button.image = NSImage(systemSymbolName: "calendar.circle.fill", accessibilityDescription: "TimeLime")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create the popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 480, height: 600)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: ContentView(viewModel: eventViewModel!)
        )
    }

    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                if let button = statusItem?.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    // Activate the app when popover is shown
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}
