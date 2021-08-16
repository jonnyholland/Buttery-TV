//
//  SharingControlsBar.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/11/21.
//

import SwiftUI
import AVKit
import Buttery
import Combine

struct SharingControlsBar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var window: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    @EnvironmentObject var controller: MasterFileController
    
    @State private var showVolume = false
    @State private var showInfo = false
    @State private var editTitle = false
    @State private var newTitle = ""
    @State private var editDuration = false
    @State private var newDuration = ""
    @State private var editKey = false
    @State private var newKey = ""
    @State private var showFileType = false
    @State private var showFileName = false
    @State private var showFileNameEdit = false
    @State private var showFileNameDelete = false
    @State private var showDurationTitle = false
    @State private var showKeyTitle = false
    @State private var showNominalFRLong = false
    @State private var showAvgFRLong = false
    @State private var showSizeLong = false
    
    @State private var showEjectTitle = false
    @State private var showShareTitle = false
    @State private var showGoBackTitle = false
    @State private var showPlayToggleTitle = false
    @State private var showGoForwardTitle = false
    
    @State private var showPreviousImage = false
    @State private var showNextImage = false
    
    var body: some View {
        if controller.file != nil {
            HStack(spacing: 30) {
                
                VStack {
                    Image(systemName: "eject.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(showEjectTitle ? .bRed:.accentGray)
                    if showEjectTitle {
                        Text("Eject").callout(textColor: .accentGray)
                    }
                }
                .fixedSize()
                .onHover(perform: { hovering in
                    showEjectTitle = hovering
                })
                .onTap {
                    controller.stopSharing()
                    controller.file = nil
                }
                
                if controller.file?.type == .video {
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: controller.defaultSeek.1)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(showGoBackTitle ? .bColor:.accentGray)
                            if showGoBackTitle {
                                Text("Back \(String(format: "%.0f", controller.defaultSeek.0))s").callout(textColor: .accentGray)
                            }
                        }.fixedSize()
                        .onHover(perform: { hovering in
                            showGoBackTitle = hovering
                        })
                        .onTap {
                            controller.seekBackward()
                        }
                        
                        VStack {
                            Image(systemName: controller.isPlaying ? "pause":"play.fill")
                                .resizable()
                                .frame(width: 25, height: 30)
                                .foregroundColor(showPlayToggleTitle ? controller.isPlaying ? .bRed:.bColor:controller.isPlaying ? .bColor:.accentGray)
                            if showPlayToggleTitle {
                                Text(controller.isPlaying ? "Pause":"Play").callout(textColor: .accentGray)
                            }
                        }.fixedSize()
                        .onHover(perform: { hovering in
                            showPlayToggleTitle = hovering
                        })
                        .onTap {
                            controller.togglePlay()
                        }
                        
                        VStack {
                            Image(systemName: controller.defaultSeek.2)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(showGoForwardTitle ? .bColor:.accentGray)
                            if showGoForwardTitle {
                                Text("Forward \(String(format: "%.0f", controller.defaultSeek.0))s").callout(textColor: .accentGray)
                            }
                        }.fixedSize()
                        .onHover(perform: { hovering in
                            showGoForwardTitle = hovering
                        })
                        .onTap {
                            controller.seekForward()
                        }
                    }
                }
                
                VStack {
                    Image(systemName: showShareTitle ? controller.shareFile ? "pip.remove":"pip.enter":controller.shareFile ? "pip.fill":"pip.enter")
                        .resizable()
                        .frame(width: 30, height: 25)
                        .foregroundColor(showShareTitle ? controller.shareFile ? .bRed:.bColor:controller.shareFile ? .bColor:.accentGray)
                    if showShareTitle {
                        Text(controller.shareFile ? "Close":"Open").callout(textColor: .accentGray)
                    }
                }
                .fixedSize()
                .onHover(perform: { hovering in
                    showShareTitle = hovering
                })
                .onTap {
                    if controller.shareFile {
                        controller.stopSharing()
                    }
                    else {
                        controller.startSharing()
                    }
                }
                
            }
            .padding(30)
            .animation(.easeOut)
            .background(WindowMaker(window: $window, settings: .init(identifier: "ControlsView", isMovable: true, isMovableByWindowBackground: true, acceptsMouseMovedEvents: true)))
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification), perform: { _ in
                window?.isReleasedWhenClosed = true
                window?.close()
            })
            .onChange(of: window, perform: updateTitle(newValue:))
            .onAppear {
                print("ScreenShareView has appeared")
                controller.sharingControlsIsOpen = true
                window?.title = "Controls Bar"
//                window?.miniwindowTitle = "Controls Bar"
                window?.setAccessibilityTitle("Controls Bar")
                
            }
        }
    }
    
    private func updateTitle(newValue: NSWindow?) {
        window?.title = "Controls Bar"
        window?.miniwindowTitle = "Controls Bar"
        window?.setAccessibilityTitle("Controls Bar")
        window?.miniwindowImage = .init(named: "Logo")
    }

}
