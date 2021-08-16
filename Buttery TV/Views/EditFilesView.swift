//
//  EditFilesView.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/4/21.
//

import SwiftUI
import Buttery

struct EditFilesView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @CoreStorage<AVFile>(sorters: [.init(keyPath: \AVFile.position, ascending: true)]) private var files
    @State private var expandAll = false
    
    var body: some View {
        VStack {
            
            HStack {
                Action.Word(expandAll ? "Collapse All":"Expand All") {
                    expandAll.toggle()
                }
                Action.Close(color: .bBlue) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .align(.trailing)
            .padding()
            
            List(files) { file in
                EditFileCell(viewModel: .init(file), overrideExpand: $expandAll, files: files)
            }
        }
        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
        .animation(.easeOut)
        .transition(.scale)
    }
}

struct EditFilesView_Previews: PreviewProvider {
    static var previews: some View {
        EditFilesView()
    }
}
