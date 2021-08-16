//
//  Buttery_TVApp.swift
//  Buttery TV
//
//  Created by Jonathan Holland on 8/12/21.
//

import SwiftUI
import Buttery
import Preferences

@main
struct Buttery_TVApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var shareWindow: NSWindow!
    
    let pc = PersistenceController.shared
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var controller: MasterFileController = .init()
    
    let GeneralPreferenceViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .general,
            title: "General",
            toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General preferences")!
        ) {
            SharingPreferences()
        }
        
        return Preferences.PaneHostingController(pane: paneView)
    }
    let LayoutPreferenceViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .layout,
            title: "Layout",
            toolbarIcon: NSImage(systemSymbolName: "rectangle.center.inset.fill", accessibilityDescription: "Layout preferences")!
        ) {
            LayoutPreferences()
        }
        
        return Preferences.PaneHostingController(pane: paneView)
    }
    let DataPreferenceViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .data,
            title: "Data",
            toolbarIcon: NSImage(systemSymbolName: "externaldrive.connected.to.line.below", accessibilityDescription: "Data management")!
        ) {
            DataPreferences()
                .context(PersistenceController.shared.container.viewContext)
        }
        
        return Preferences.PaneHostingController(pane: paneView)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .context(pc.container.viewContext)
                .environmentObject(controller)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: Wnd.mainView.rawValue))
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                Button("Preferences...") {
                    PreferencesWindowController(
                        preferencePanes: [GeneralPreferenceViewController(), LayoutPreferenceViewController(), DataPreferenceViewController()],
                        style: .toolbarItems,
                        animated: true,
                        hidesToolbarForSingleItem: true
                    ).show()
                }.keyboardShortcut(KeyEquivalent(","), modifiers: .command)
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
                case .active:
                    Console("App is active")
                case .inactive:
                    Console("App is inactive")
                case .background:
                    Console("App is in background")
                @unknown default:
                    Console("Oh - interesti_an unexpected new value.")
            }
        }
        
        WindowGroup {
            if controller.shareFile {
                ShareView()
                    .environmentObject(controller)
            }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: Wnd.shareView.rawValue))
        
        WindowGroup {
            if controller.shareFile, controller.openSharingSeparately {
                SharingControlsBar()
                    .environmentObject(controller)
            }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: Wnd.controlsView.rawValue))
        
    }
}


final class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        return .terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
