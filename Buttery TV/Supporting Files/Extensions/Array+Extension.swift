//
//  Array+Extension.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/1/21.
//

import Foundation
import SwiftUI

extension Array where Element: Equatable {
    mutating func update(_ element: Element) {
        if let firstElement = self.first(where: { $0 == element }) {
            if let firstIndex = self.firstIndex(of: element) {
                self.insert(element, at: firstIndex)
            }
        }
    }
}
