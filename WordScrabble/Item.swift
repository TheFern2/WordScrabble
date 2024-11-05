//
//  Item.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/5/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
