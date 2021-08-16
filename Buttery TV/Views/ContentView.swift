//
//  ContentView.swift
//  Buttery TV
//
//  Created by Jonathan Holland on 8/12/21.
//

import SwiftUI
import CoreData
import AVKit
import Buttery

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var controller: MasterFileController
    
    @State private var window: NSWindow?
    
    @CoreStorage<AVFile>(sorters: [.init(keyPath: \AVFile.position, ascending: true)]) private var files
    
    @State private var dragOver = false
    @AppStorage("viewLayout") var viewLayout: ViewLayout = .grid
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150, maximum: 150))]
    @State var gridLayout: [GridItem] = [ GridItem() ]
    
    @State private var showNetworkStatusLabel = false
    @State private var showConnetionTypeLabel = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 15) {
                    
                    if controller.viewLayout == .grid {
                        HStack(alignment: .top) {
                            VStack(spacing: 15) {
                                TV_View(isOn: $controller.shareFile) {
                                    if controller.shareFile, controller.file?.type == .video {
                                        VideoPlayer(player: controller.player)
                                    }
                                    else if controller.file != nil {
                                        controller.splashContent()
                                    }
                                    else {
                                        Image("NoContent")
                                            .aspectRatio(contentMode: .fit)
                                            .animation(.interactiveSpring())
                                            .shadow(color: Color.accentGray, radius: 8)
                                    }
                                }
                                .frame(width: controller.file != nil ? 500:300, height: controller.file != nil ? 350:200, alignment: .center)
                                
                                MasterControlsBar()
                                
                            }
                            
                            InfoPanel(files: files)
                                .offset(x: -50, y: 50)
                        }
                        
                        if controller.file != nil {
                            Divider()
                                .padding()
                        }
                    }
                    
                    FileListView()
                }
            }
            .onDrop(of: ["public.url", "public.file-url"], isTargeted: nil) { items in
                for item in items {
                    if let identifier = item.registeredTypeIdentifiers.first {
                        if identifier == "public.url" || identifier == "public.file-url" {
                            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                                DispatchQueue.main.async {
                                    if let urlData = urlData as? Data {
                                        let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                                        createNewFile(from: url)
                                    }
                                }
                            }
                        }
                    }
                }
                return true
            }
            .frame(minWidth: controller.viewLayout == .grid ? 500:350, minHeight: 300)
            .background(WindowMaker(window: $window, settings: .init(identifier: "MainView")))
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                ToolbarItem(placement: .navigation) {
                    HStack {
                        Image.network()
                            .header(textColor: controller.networkMonitor.statusLabel.1)
                            .foregroundColor(controller.networkMonitor.statusLabel.1)
                        if showNetworkStatusLabel {
                            Text("\(controller.networkMonitor.statusLabel.0) - \(controller.networkMonitor.typeLabel)").body()
                        }
                    }
                    .pill()
                    .fixedSize()
                    .onHover(perform: { hovering in
                        showNetworkStatusLabel = hovering
                    })
                }
            }
//            .onChange(of: window, perform: updateTitle(newValue:))
            .onAppear {
                Console("viewContext: \(viewContext)")
            }
        }
    }

    func createNewFile(from url: URL) {
        print("Creating file from url: \(url)")
        
        let newAVFile = AVFile(context: viewContext)
        newAVFile.create(from: url, position: Int16(files.endIndex + 1))
        try? viewContext.save()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
