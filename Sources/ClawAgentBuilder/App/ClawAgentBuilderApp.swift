import AppKit
import SwiftUI

@main
struct ClawAgentBuilderApp: App {
    @State private var store = BuilderStore()
    @Environment(\.scenePhase) private var scenePhase
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        // Hand the store to the AppDelegate so pre-termination flushes
        // and quit-handling can call through to it. Done at init so the
        // delegate is wired before the first launch event fires.
        AppDelegate.sharedStore = _store.wrappedValue
    }

    var body: some Scene {
        WindowGroup("CLAW AGENT BUILDER", id: "main") {
            ContentView(store: store)
                .frame(minWidth: 980, minHeight: 760)
                .preferredColorScheme(.dark)
                .tint(OakPalette.brass)
                .task {
                    // Restore any interrupted session and then start
                    // the background autosave loop so the user never
                    // loses work again.
                    store.restoreAutosaveIfAvailable()
                    store.startAutosave()
                }
        }
        .defaultSize(width: 1_080, height: 820)
        .onChange(of: scenePhase) { _, newPhase in
            // Flush immediately when the window goes to background or
            // the app is about to be hidden — guarantees the latest
            // state is on disk even if the user force-quits.
            if newPhase != .active {
                store.flushAutosave()
            }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Set from the SwiftUI App initializer so the delegate can flush
    /// the draft on termination without pulling in a second store.
    static var sharedStore: BuilderStore?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Quit → save. Belt-and-suspenders on top of the scenePhase flush,
    /// so ⌘Q and Force-Quit both leave the autosave file current.
    func applicationWillTerminate(_ notification: Notification) {
        Self.sharedStore?.flushAutosave()
    }

    /// Standard macOS behavior: closing the last window quits the app.
    /// Matches user expectations for a single-window builder.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
