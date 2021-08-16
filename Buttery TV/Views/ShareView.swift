//
//  ShareView.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 7/3/21.
//

import SwiftUI
import AVKit
import Buttery

struct ShareView: View {
    @State private var window: NSWindow?
    
    @EnvironmentObject var controller: MasterFileController
    @State private var showClose = false
    
    var body: some View {
        GeometryReader { proxy in
            if window != nil {
                if controller.file != nil {
                    
                    if controller.file?.type == .video {
                        if let player = controller.player {
                            VideoPlayer(player: player)
                                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
//                                .cornerRadius(8)
                        }
                    }
                    else {
                        controller.splashContent()
                    }
                }
            }
        }
        .frame(minWidth: controller.unwrappedWidth, minHeight: controller.unwrappedHeight)
        .ignoresSafeArea(.container, edges: .all)
        .background(WindowMaker(window: $window, settings: .init(identifier: "ShareView", showCloseButton: false, showMiniaturizeButton: false, showZoomButton: false, backgroundColor: nil, isOpaque: nil, isMovable: true, isMovableByWindowBackground: true, acceptsMouseMovedEvents: true, titleVisibility: .hidden, titleBarAppearsTransparent: true, showsToolbarButton: false, toolbarIsVisible: false, contentAspectRatio: controller.unwrappedAspectRatio)))
        .onReceive(controller.sharingCode.publisher, perform: { newValue in
            if newValue == MasterFileController.shareWindowCode {
//                window?.isReleasedWhenClosed = true
                window?.close()
                controller.sharingWindowIsOpen = false
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification), perform: { _ in
            window?.isReleasedWhenClosed = true
            window?.close()
        })
        .onChange(of: window, perform: updateTitle(newValue:))
        .onAppear {
            print("ScreenShareView has appeared")
            controller.sharingWindowIsOpen = true
            if controller.file?.type == .video, controller.autoPlayVideos {
                controller.togglePlay()
            }
        }
    }
    
    private func updateTitle(newValue: NSWindow?) {
        window?.title = "Share View"
        window?.miniwindowTitle = "Share View"
        window?.setAccessibilityTitle("Share View")
        
        if let window = newValue {
            print("Share Window was set. Adding to controller's array for storage.")
            if !controller.openWindows.contains(window) {
                controller.openWindows.append(window)
                print("Added.")
            }
        }
        else {
            print("Share Window is nil.")
        }
    }
}


