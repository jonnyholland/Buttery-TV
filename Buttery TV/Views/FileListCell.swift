//
//  FileListCell.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/11/21.
//

import SwiftUI
import Buttery
import AVKit
import Combine

struct FileListCell: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var controller: MasterFileController
    @ObservedObject var viewModel: FileViewModel
    
    var body: some View {
        HStack {
            ///Position among the array
            Text("30")
            .hidden()
            .padding(4)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Text(viewModel.file.position.description).bold().body(textColor: .bBlue))
            .padding(6)
            
            ///Thumnail - adapts to Grid/List
            if controller.file == viewModel.file {
                Image(systemName: controller.isPlaying ? "play.tv":"tv")
                    .resizable()
                    .foregroundColor(controller.isPlaying ? .bRed:.accentGray)
                    .frame(width: 30, height: 25, alignment: .center)
            }
            
            viewModel.showThumbnail(with: Color.clear, for: .list)
            
            ///File name
            if let additionalName = viewModel.file.additionalName {
                Text(additionalName).bold().custom(font: .body)
                
                Text(viewModel.file.name).custom(font: .caption2, textColor: .accentGray)
            }
            else {
                Text(viewModel.file.name).custom(font: .body)
            }
            
            if controller.file == viewModel.file {
                if controller.sharingWindowIsOpen, controller.isPlaying {
                    Text("Playing").header(textColor: .accentGrayLight)
                } else {
                    Text("Current File").header(textColor: .accentGrayLight)
                }
            }
            
            Spacer()
            
            ///Menu button
            Menu {
                if controller.file == viewModel.file {
                    Button("\(controller.isPlaying ? "Stop":"Start") Playing") {
                        controller.togglePlay()
                    }
                    if controller.sharingWindowIsOpen {
                        Button("Stop Sharing") {
                            controller.stopSharing()
                        }
                    }
                    if !controller.sharingControlsIsOpen {
                        Button("Open Controls") {
                            controller.analyzeControlWindow()
                        }
                    }
                    Button("Eject") {
                        if controller.sharingWindowIsOpen {
                            controller.stopSharing()
                        }
                        controller.file = nil
                    }
                } else {
                    Button("Select") {
                        controller.cycleTo(viewModel.file)
                    }
                    Button("Start Sharing") {
                        controller.cycleTo(viewModel.file)
                        controller.startSharing()
                    }
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .title()
            }
            .frame(idealWidth: 30, maxWidth:50)

        }
        .padding(controller.file == viewModel.file ? 8:0)
        .border(controller.file == viewModel.file ? Color.bColor:.clear, width: 5)
        .cornerRadius(5)
    }
    
}
