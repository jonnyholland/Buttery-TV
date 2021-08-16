//
//  SharingPreferences.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/11/21.
//

import SwiftUI
import Preferences

struct SharingPreferences: View {
    @AppStorage("autoPlayVideos") var autoPlayVideos = false
    @AppStorage("openSharingSeparately") var openSharingSeparately = false
    @AppStorage("autoCloseWindowEditor") var autoCloseWindowEditor = false
    @AppStorage("autoCloseWindowTimer") var autoCloseWindowTimer = 0
    
    private let contentWidth: Double = 450.0
    
    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Videos") {
                Toggle("Auto-play when sharing window is opened", isOn: $autoPlayVideos)
                
                Text("When sharing and the file is a video, this setting will automatically play the video once the sharing view is opened.")
                    .preferenceDescription()
            }
            Preferences.Section(title: "File Controls") {
                Toggle("Open controls separately", isOn: $openSharingSeparately)
                
                Text("The app will open the control bar for the file being shared into a new window. If the view is set to \"list\", then the application will override this setting and automatically open.")
                    .preferenceDescription()
            }
            Preferences.Section(label: {
                Toggle("Auto close share window", isOn: $autoCloseWindowEditor)
            }) {
                Picker("", selection: $autoCloseWindowTimer) {
                    Text("Immedately").tag(0)
                    Text("Wait 5 seconds").tag(1)
                    Text("Wait 10 seconds").tag(2)
                    Text("Wait 15 seconds").tag(2)
                }
                .labelsHidden()
                .frame(width: 120.0)
                Text("The app will automatically close the share window once the file duration is completed.")
                    .preferenceDescription()
            }
        }
    }
}

struct GeneralPreferences_Previews: PreviewProvider {
    static var previews: some View {
        SharingPreferences()
    }
}
