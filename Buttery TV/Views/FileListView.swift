//
//  FileListView.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/11/21.
//

import SwiftUI
import Buttery

struct FileListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var controller: MasterFileController
    
    @CoreStorage<AVFile>(sorters: [.init(keyPath: \AVFile.position, ascending: true)]) private var files
    
    private var gridItemLayout: [GridItem] {
        switch viewLayout {
            case .grid:
                return [ GridItem(.adaptive(minimum: 150, maximum: 150)) ]
            case .list:
                return [ GridItem() ]
        }
    }
    private var gridLayout: [GridItem] = [ GridItem() ]
    @State private var editAllFile = false
    @AppStorage("viewLayout") var viewLayout: ViewLayout = .grid
    
    var body: some View {
        ZStack {
            LazyVGrid(columns: gridLayout, spacing: 8) {
                Text("Click or drop files").font(.system(size: 60, weight: .medium, design: .rounded)).foregroundColor(controller.files.isEmpty ? .accentGrayLight:.accentMilk)
                Image(systemName: "rectangle.dashed.and.paperclip")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .font(.system(size: 60, weight: .regular, design: .rounded))
                    .foregroundColor(controller.files.isEmpty ? .accentGrayLight:.accentMilk)
                    .onTap {
                        openFiles()
                    }
            }
            LazyVGrid(columns: gridItemLayout, spacing: 30) {
                Section(header: HStack {
                    Spacer()
                    if !files.isEmpty {
                        Action.Edit("Edit All", color: .bColor) {
                            editAllFile.toggle()
                        }
                        Action.Add(color: .bGreen) {
                            openFiles()
                        }
                    }
                }) {
                    ForEach(files) { file in
                        FileCell(viewModel: .init(file))
                            .onTap {
                                controller.cycleTo(file)
                            }
                        //                                        .onDrag { NSItemProvider(object: file.url as NSURL) }
                    }.onInsert(of: [.url], perform: insert(at:itemProviders:))
                }
                
            }
        }
        .padding(.all, 10)
        .sheet(isPresented: $editAllFile) {
            EditFilesView()
        }
    }
    
    private func insert(at index: Int, itemProviders: [NSItemProvider]) {
        itemProviders.reversed().forEach({ _ = $0.loadObject(ofClass: URL.self) { url, error in
            url.map { controller.files.insert(.init($0), at: index)}
        }})
    }
    private func openFiles() {
        Files.open(multiple: true, documentTypes: [.movie, .mpeg4Movie, .jpeg, .pdf, .png]) {
            
        } onDocumentsPicked: { urls in
            print("Received \(urls.count) urls")
            urls.forEach({ createNewFile(from: $0) })
        }
    }
    func createNewFile(from url: URL) {
        print("Creating file from url: \(url)")
        
        let newAVFile = AVFile(context: viewContext)
        newAVFile.create(from: url, position: Int16(files.endIndex + 1))
        try? viewContext.save()
    }
    
}

