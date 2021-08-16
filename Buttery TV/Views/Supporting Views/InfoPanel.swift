//
//  InfoPanel.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/3/21.
//

import SwiftUI
import Buttery

struct InfoPanel: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var controller: MasterFileController
    
    var files: FetchedResults<AVFile>
    
    @State private var showInfo = true
    @State private var editTitle = false
    @State private var newTitle = ""
    @State private var newPosition = ""
    @State private var editPosition = false
    @State private var editDuration = false
    @State private var newDuration = ""
    @State private var editKey = false
    @State private var newKey = ""
    @State private var newNotes = ""
    @State private var editNotes = false
    @State private var showFileType = false
    @State private var showFileName = false
    @State private var showFileNameEdit = false
    @State private var showFileNameDelete = false
    @State private var showPosition = false
    @State private var showDurationTitle = false
    @State private var showKeyTitle = false
    @State private var showNoteTitle = false
    
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
        if let file = controller.file {
            GeometryReader { proxy in
                HStack(alignment: .top) {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.accentGray)
                    
                    VStack(spacing: 15) {
                        VStack {
                            VStack {
                                Text(file.name).bold().body(textColor: showFileName && file.additionalName == nil ? .bColor:.accentGray)
                                if let additionalName = file.additionalName {
                                    HStack {
                                        if showFileName {
                                            VStack {
                                                Image.garbage()
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundColor(showFileNameDelete ? .bRed:.accentGray)
                                                if showFileNameDelete {
                                                    Text("Delete").custom(font: .caption2, textColor: .accentGrayMedium)
                                                }
                                            }
                                            .onHover(perform: { hovering in
                                                showFileNameDelete = hovering
                                            })
                                            .onTap {
                                                file.additionalName = nil
                                                try? viewContext.save()
                                                newTitle.removeAll()
                                            }
                                        }
                                        Text(additionalName).body(textColor: .accentGray)
                                            .onTap {
                                                editTitle.toggle()
                                            }
                                        if showFileName {
                                            VStack {
                                                Image.edit()
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundColor(showFileNameEdit ? .bColor:.accentGray)
                                                if showFileNameEdit {
                                                    Text("Edit").custom(font: .caption2, textColor: .accentGrayMedium)
                                                }
                                            }
                                            .onHover(perform: { hovering in
                                                showFileNameEdit = hovering
                                            })
                                            .onTap {
                                                editTitle.toggle()
                                            }
                                        }
                                    }
                                }
                                if showFileName {
                                    Text(file.additionalName == nil ? "Add a custom name for clarity":"Additional Title").custom(font: .caption2, textColor: .accentGrayMedium)
                                    
                                    VStack {
                                        switch file.type {
                                            case .video:
                                                Image(systemName: "film.fill")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundColor(.accentGray)
                                            case .image:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundColor(.accentGray)
                                            case .audio:
                                                Image(systemName: "waveform")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundColor(.accentGray)
                                        }
                                        Text(file.type == .video ? "Video file":file.type == .image ? "Image file":"Audio file").custom(font: .caption2, textColor: .accentGrayMedium)
                                    }
                                }
                            }
                            .onHover(perform: { hovering in
                                showFileName = hovering
                            })
                            .onTap {
                                if file.additionalName != nil {
                                    file.additionalName = nil
                                    try? viewContext.save()
                                    newTitle.removeAll()
                                }
                                else {
                                    newTitle = file.name
                                }
                                editTitle.toggle()
                            }
                            
                            if editTitle {
                                HStack {
                                    TextField("Custom name...", text: $newTitle, onCommit:  {
                                        editTitle.toggle()
                                        controller.file?.additionalName = newTitle
                                        try? viewContext.save()
                                    })
                                    .body()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(minWidth: proxy.size.width * 0.15)
                                    .overlay(HStack {
                                        Spacer()
                                        Image(systemName: "xmark.circle")
                                            .callout(textColor: .accentGray)
                                            .padding(.trailing, 6)
                                            .onTap {
                                                newTitle.removeAll()
                                            }
                                    })
                                }
                            }
                        }
                        
                        Divider()
                        
                        if file.type == .video {
                            VStack {
                                Image(systemName: "film")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.accentGray)
                                if showNominalFRLong {
                                    Text("Nominal Frame Rate").custom(font: .caption2, textColor: .accentGrayMedium)
                                }
                                Text(String(format: "%.2f", controller.unwrappedFrameRate))
                            }.fixedSize()
                            .onHover { isHovering in
                                showNominalFRLong = isHovering
                            }
                            VStack {
                                Image(systemName: "list.and.film")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.accentGray)
                                if showAvgFRLong {
                                    Text("Average Frame Rate").custom(font: .caption2, textColor: .accentGrayMedium)
                                }
                                Text(String(format: "%.2f", controller.videoFR))
                            }.fixedSize()
                            .onHover { isHovering in
                                showAvgFRLong = isHovering
                            }
                        }
                        
                        VStack {
                            Image(systemName: "aspectratio")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.accentGray)
                            if showSizeLong {
                                Text("Aspect Ratio (width x height)").custom(font: .caption2, textColor: .accentGrayMedium)
                            }
                            Text("\(String(format: "%.0f", controller.unwrappedWidth)) x \(String(format: "%.0f", controller.unwrappedHeight))")
                        }.fixedSize()
                        .onHover { isHovering in
                            showSizeLong = isHovering
                        }
                        
                        Divider()
                        
                        VStack {
                            VStack {
                                Image(systemName: "list.number")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(showPosition ? .bColor:.accentGray)
                                
                                if showPosition {
                                    Text("Position (e.g., 1, 2, or 3)")
                                        .custom(font: .caption2, textColor: .accentGrayMedium)
                                }
                                Text(file.position.description).body()
                            }
                            .onHover(perform: { hovering in
                                showPosition = hovering
                            })
                            .onTap {
                                newPosition = file.position.description
                                editPosition.toggle()
                            }
                            if editPosition {
                                HStack {
                                    TextField("Position among the files", text: $newPosition, onCommit: {
                                        editPosition.toggle()
                                        let oldPosition: Int16 = file.position
                                        let position: Int16 = .init(newPosition) ?? 0
                                        
                                        files.forEach({ file in
                                            if file.position >= position && file.position < oldPosition {
                                                file.position += 1
                                            }
                                            else if file.position <= position && file.position > oldPosition {
                                                file.position -= 1
                                            }
                                        })
                                        controller.file?.position = Int16(newPosition) ?? 0
                                        try? viewContext.save()
                                    })
                                    .body()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(minWidth: proxy.size.width * 0.15)
                                    .overlay(HStack {
                                        Spacer()
                                        if !newPosition.isEmpty {
                                            Image(systemName: "xmark.circle")
                                                .callout(textColor: .accentGray)
                                                .padding(.trailing, 6)
                                                .onTap {
                                                    newPosition.removeAll()
                                                }
                                        }
                                    })
                                }
                            }
                        }
                        
                        VStack {
                            VStack {
                                Image(systemName: "timer.square")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(showDurationTitle ? (file.duration > 0 ? .bRed:.bColor):file.duration > 0 ? .bColor:.accentGray)
                                
                                if showDurationTitle {
                                    Text("Play duration (e.g., 3 or 5.25).")
                                        .custom(font: .caption2, textColor: .accentGrayMedium)
                                }
                                if file.duration > 0 {
                                    Text(String(format: "%.2f", file.duration)).body()
                                }
                            }
                            .onHover(perform: { hovering in
                                showDurationTitle = hovering
                            })
                            .onTap {
                                if file.duration > 0 {
                                    file.duration = 0
                                    try? viewContext.save()
                                    newDuration.removeAll()
                                }
                                else {
                                    newDuration = file.duration > 0 ? String(format: "%.2f", file.duration):""
                                }
                                editDuration.toggle()
                            }
                            if editDuration {
                                HStack {
                                    TextField("Duration of playback...", text: $newDuration, onCommit:  {
                                        editDuration.toggle()
                                        controller.file?.duration = Double(self.newDuration) ?? 0
                                        try? viewContext.save()
                                    })
                                    .body()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(minWidth: proxy.size.width * 0.15)
                                    .overlay(HStack {
                                        Spacer()
                                        if !newDuration.isEmpty {
                                            Image(systemName: "xmark.circle")
                                                .callout(textColor: .accentGray)
                                                .padding(.trailing, 6)
                                                .onTap {
                                                    newDuration.removeAll()
                                                }
                                        }
                                    })
                                }
                            }
                        }
                        
                        VStack {
                            VStack {
                                Image(systemName: file.keyword != nil ? "tag.fill":"tag")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(showKeyTitle ? (file.keyword != nil ? .bRed:.bColor):file.keyword != nil ? .bColor:.accentGray)
                                
                                if showKeyTitle {
                                    Text("Transition Key (e.g., \"When he says...\"").custom(font: .caption2, textColor: .accentGrayMedium)
                                }
                                
                                if let keyTransition = file.keyword {
                                    Text(keyTransition).body()
                                }
                            }
                            .onHover(perform: { hovering in
                                showKeyTitle = hovering
                            })
                            .onTap {
                                if file.keyword != nil {
                                    controller.file?.keyword = nil
                                    try? viewContext.save()
                                    newKey.removeAll()
                                }
                                else {
                                    newKey = file.keyword ?? ""
                                }
                                editKey.toggle()
                            }
                            if editKey {
                                HStack {
                                    TextField("Keyword (e.g., \"Paragraphs 5-6\" or \"When he says...\")", text: $newKey, onCommit:  {
                                        //                                                    file.wrappedValue.keyTransition = newKey
                                        controller.file?.keyword = newKey
                                        Console("viewContext is: \(viewContext.hasChanges)")
                                        try? viewContext.save()
                                        Console("viewContext is: \(viewContext.hasChanges)")
                                        editKey.toggle()
                                    })
                                    .body()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(minWidth: proxy.size.width * 0.15)
                                    .overlay(HStack {
                                        Spacer()
                                        if !newKey.isEmpty {
                                            Image(systemName: "xmark.circle")
                                                .callout(textColor: .accentGray)
                                                .padding(.trailing, 6)
                                                .onTap {
                                                    newKey.removeAll()
                                                }
                                        }
                                    })
                                }
                            }
                        }
                        
                        VStack {
                            VStack {
                                Image(systemName: file.notes != nil ? "note.text":"note")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(showNoteTitle ? (file.notes != nil ? .bRed:.bColor):file.notes != nil ? .bColor:.accentGray)
                                
                                if showNoteTitle {
                                    Text("Notes").custom(font: .caption2, textColor: .accentGrayMedium)
                                }
                                
                                if let notes = file.notes {
                                    Text(notes).body()
                                }
                            }
                            .onHover(perform: { hovering in
                                showNoteTitle = hovering
                            })
                            .onTap {
                                if file.notes != nil {
                                    controller.file?.notes = nil
                                    try? viewContext.save()
                                    newNotes.removeAll()
                                }
                                else {
                                    newNotes = file.notes ?? ""
                                }
                                editNotes.toggle()
                            }
                            if editNotes {
                                HStack {
                                    TextField("Notes (e.g., \"Play together with...\")", text: $newNotes, onCommit:  {
                                        controller.file?.notes = newNotes
                                        try? viewContext.save()
                                        editNotes.toggle()
                                    })
                                    .body()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(minWidth: proxy.size.width * 0.15)
                                    .overlay(HStack {
                                        Spacer()
                                        if !newNotes.isEmpty {
                                            Image(systemName: "xmark.circle")
                                                .callout(textColor: .accentGray)
                                                .padding(.trailing, 6)
                                                .onTap {
                                                    newNotes.removeAll()
                                                }
                                        }
                                    })
                                }
                            }
                        }
                        
                    }
                    .padding(.vertical, 10)
                    .frame(minWidth: 150, maxWidth: 300)
                    .pill()
                    .body()
                    .fixedSize()
                }
                .animation(.easeOut)
            }
        }
//        .offset(x: -60, y: 80)
    }
}
