//
//  FileGridCell.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 7/5/21.
//

import SwiftUI
import Buttery
import AVKit

struct FileGridCell: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var controller: MasterFileController
    @ObservedObject var viewModel: FileViewModel
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                viewModel.showThumbnail(with: controller.file == viewModel.file ? Color.bBlue:Color.clear, for: .grid)
                
                Text("30")
                    .hidden()
                    .padding(4)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Text(viewModel.file.position.description).bold().body(textColor: .bBlue))
                    .padding(6)
            }
            
            if let additionalName = viewModel.file.additionalName {
                Text(additionalName).bold().custom(font: .caption, textColor: .accentGray)
            }
            else {
                Text(viewModel.file.name).custom(font: .caption2, textColor: .accentGray)
            }
        }
        .padding()
        .frame(width: 150, height: 150)
    }
    
}
