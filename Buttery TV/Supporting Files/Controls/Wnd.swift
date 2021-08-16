//
//  Wnd.swift
//  Buttery TV
//
//  Created by Jonathan Holland on 8/12/21.
//

import AppKit

enum Wnd: String, CaseIterable {
    case mainView = "MainView"
    case shareView = "ShareView"
    case controlsView = "ControlsView"
    
    func open(){
        if let url = URL(string: "buttery://\(self.rawValue)") {
            print("opening \(self.rawValue)")
            NSWorkspace.shared.open(url)
        }
    }
}
