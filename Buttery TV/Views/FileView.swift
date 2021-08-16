//
//  FileView.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/1/21.
//

import SwiftUI
import Buttery

struct FileView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var file: File
    
    init(file: Binding<File>) {
        _file = file
        self._newTitle = State<String>(initialValue: file.wrappedValue.add_title ?? "")
        self._newDuration = State<String>(initialValue: String(format: "%.2f", file.wrappedValue.duration))
        self._newKey = State<String>(initialValue: file.wrappedValue.keyTransition ?? "")
    }
    
    @State private var editTitle = false
    @State private var newTitle = ""
    @State private var editDuration = false
    @State private var newDuration = ""
    @State private var editKey = false
    @State private var newKey = ""
    @State private var editNotes = false
    @State private var notes = ""
//    @State private var no
    
    private var hasChanges: Bool {
        (!newTitle.isEmpty && file.add_title != newTitle) || (!newDuration.isEmpty && file.duration != Double(newDuration)) || (!newKey.isEmpty && file.keyTransition != newKey) || (!notes.isEmpty && file.notes != notes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Action.Close {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                if hasChanges {
                    Action.Save {
                        save()
                    }
                }
            }
            
            Text(file.name).bold().title()
            
            VStack {
                Text("Additional Title").header(textColor: .accentGray)
                TextField("Custom title", text: $newTitle)
                .body()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(HStack {
                    Spacer()
                    Image.clear()
                        .header(textColor: .accentGray)
                        .padding(.trailing, 6)
                        .onTap {
                            newTitle.removeAll()
                        }
                })
            }
            VStack {
                Text("Duration").header(textColor: .accentGray)
                TextField("Playback duration", text: $newDuration)
                .body()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(HStack {
                    Spacer()
                    Image.clear()
                        .header(textColor: .accentGray)
                        .padding(.trailing, 6)
                        .onTap {
                            newDuration.removeAll()
                        }
                })
            }
            VStack {
                Text("Transition Key").header(textColor: .accentGray)
                TextField("e.g., \"Isaiah 33:24 says...\"", text: $newKey)
                .body()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(HStack {
                    Spacer()
                    Image.clear()
                        .header(textColor: .accentGray)
                        .padding(.trailing, 6)
                        .onTap {
                            newDuration.removeAll()
                        }
                })
            }
            VStack {
                Text("Notes").header(textColor: .accentGray)
                Editor.Text(text: $notes)
            }
        }
        .padding()
        .background(Color.fleshColor)
        .ignoresSafeArea()
        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 250, maxHeight: .infinity)
    }
    
    private func save() {
        if !newTitle.isEmpty {
            file.add_title = newTitle
        }
        if !newDuration.isEmpty {
            file.duration = Double(self.newDuration) ?? 0
        }
        if !newKey.isEmpty {
            file.keyTransition = newKey
        }
        if !notes.isEmpty {
            file.notes = notes
        }
    }
}

//struct FileView_Previews: PreviewProvider {
//    static var previews: some View {
//        FileView()
//    }
//}
