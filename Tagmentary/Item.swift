//
//  Item.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/21/24.
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
