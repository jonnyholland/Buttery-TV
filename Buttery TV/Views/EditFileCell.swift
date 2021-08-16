//
//  EditFileCell.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/4/21.
//

import SwiftUI
import Buttery

struct EditFileCell: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var controller: MasterFileController
    @ObservedObject var viewModel: FileViewModel
    @Binding var overrideExpand: Bool
    
    var files: FetchedResults<AVFile>
    
    @State private var expandCell = false
    
    var body: some View {
        VStack {
            
            HStack {
                viewModel.showThumbnail(with: .init(width: 50, height: 50))
                
                Text(viewModel.file.name).header()
                
                Spacer()
                Image(systemName: expandCell ? "chevron.down":"chevron.left")
            }
            .onTap {
                expandCell.toggle()
            }
            
            if expandCell {
                VStack {
                    HStack {
                        Text("Name").header(textColor: .accentGray)
                        TextField("Provide an additional name for clarity", text: $viewModel.additionalName, onCommit: {
                            viewModel.file.additionalName = viewModel.additionalName
                            try? viewContext.save()
                        })
                        .body()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Position").header(textColor: .accentGray)
                        TextField("Position among the files", text: $viewModel.positionString, onCommit: {
                            viewModel.position = Int16(viewModel.positionString) ?? 0
                            let oldPosition: Int16 = viewModel.file.position
                            let position: Int16 = viewModel.position
                            
                            files.forEach({ file in
                                if file.position >= position && file.position < oldPosition {
                                    file.position += 1
                                }
                                else if file.position <= position && file.position > oldPosition {
                                    file.position -= 1
                                }
                            })
                            
                            viewModel.file.position = Int16(viewModel.positionString) ?? 0
                            try? viewContext.save()
                        })
                        .body()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Duration").header(textColor: .accentGray)
                        TextField("Provide a duration", text: $viewModel.durationString, onCommit: {
                            viewModel.file.duration = Double(viewModel.durationString) ?? 0
                            try? viewContext.save()
                        })
                        .body()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Keyword").header(textColor: .accentGray)
                        TextField("Provide a keyword", text: $viewModel.keyword, onCommit: {
                            viewModel.file.keyword = viewModel.keyword
                            try? viewContext.save()
                        })
                        .body()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Notes").header(textColor: .accentGray)
                        
                        TextField("Additional Notes", text: $viewModel.notes, onCommit: {
                            viewModel.file.notes = viewModel.notes
                            try? viewContext.save()
                        })
                        .body()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(8)
            }
        }
        .onChange(of: overrideExpand) { newValue in
            expandCell = newValue
        }
    }
    
}
