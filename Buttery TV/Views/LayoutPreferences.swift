//
//  LayoutPreferences.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/10/21.
//

import SwiftUI
import Preferences

struct LayoutPreferences: View {
    @AppStorage("viewLayout") var viewLayout: ViewLayout = .grid
    
    private let contentWidth: Double = 450.0
    
    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Layout") {
                Preferences.Section(title: "") {
                    Picker("", selection: $viewLayout) {
                        Text("Grid").tag(ViewLayout.grid)
                        Text("List").tag(ViewLayout.list)
                    }
                    .labelsHidden()
                    .frame(width: 120.0)
                    
                    Text("A Grid layout transforms the view to mainly show the thumbnail of the file with supporting information strategically placed around it. A List layout transforms the view to show the files as part of a list - when a file is selected the controls and file are opened in separate windows.")
                        .preferenceDescription()
                }
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        LayoutPreferences()
    }
}


