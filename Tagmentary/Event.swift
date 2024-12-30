//
//  Item.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/21/24.
//

import Foundation
import SwiftData
import Charts

@Model
final class Event {
    var timestamp: Date
    @Relationship(deleteRule: .nullify) var storedTag: Tag?
    var value: Double
    var tag: Tag { get{ storedTag! } set { storedTag = newValue } }

    init(timestamp: Date, tag: Tag, value: Double) {
        self.timestamp = timestamp
        self.storedTag = tag
        self.value = value
    }
}

