//
//  DataPreferences.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/10/21.
//

import SwiftUI
import Preferences
import Buttery

struct DataPreferences: View {
    @Environment(\.managedObjectContext) private var viewContext
    @CoreStorage<AVFile>(sorters: [.init(keyPath: \AVFile.position, ascending: true)]) private var files
    
    private let contentWidth: Double = 450.0
    
    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Data") {
                Preferences.Section(title: "") {
                    Menu {
                        Text("This cannot be undone")
                        Button("Yes, delete all") {
                            deleteAll()
                        }
                        Button("Cancel") {}
                    } label: {
                        Text("Delete all files")
                    }

                    Text("This will delete all files. If the file is synced with iCloud, it will be deleted there, as well.")
                        .preferenceDescription()
                }
            }
        }
        .onAppear {
            Console("viewContext: \(viewContext)")
        }
    }
    
    private func deleteAll() {
        files.forEach({ viewContext.delete($0)})
        try? viewContext.save()
    }
}

struct DataPreferences_Previews: PreviewProvider {
    static var previews: some View {
        DataPreferences()
    }
}
