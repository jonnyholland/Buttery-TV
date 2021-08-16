//
//  FileCell.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/11/21.
//

import SwiftUI
import Buttery

struct FileCell: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var controller: MasterFileController
    @ObservedObject var viewModel: FileViewModel
    
    @CoreStorage<AVFile>(sorters: [.init(keyPath: \AVFile.position, ascending: true)]) private var files
    
    @AppStorage("viewLayout") var viewLayout: ViewLayout = .grid
    
    var body: some View {
        switch viewLayout {
            case .grid:
                FileGridCell(viewModel: viewModel)
                    .contextMenu {
                        Menu {
                            Text("Are you sure? This CANNOT be undone.")
                            Button("Yes, delete this file") {
                                withAnimation(.spring()) {
                                    if controller.file == viewModel.file {
                                        controller.stopSharing()
                                        controller.file = nil
                                    }
                                    let position: Int16 = viewModel.file.position
                                    
                                    viewContext.delete(viewModel.file)
                                    
                                    files.forEach({ file in
                                        if file.position > position {
                                            file.position -= 1
                                        }
                                    })
                                    
                                    try? viewContext.save()
                                }
                            }
                            Button("No, cancel") {}
                        } label: {
                            Label("Delete file", systemImage: "trash").foregroundColor(.bRed)
                        }
                        if controller.file != viewModel.file, controller.shareFile {
                            Button {
                                controller.file = viewModel.file
                            } label: {
                                Label("Replace currently showing file with this one", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
            case .list:
                FileListCell(viewModel: viewModel)
        }
    }
}

