//
//  Item.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/21/24.
//

import Foundation
import SwiftData

@Model
final class Event {
    var timestamp: Date
    var numericValues: [String : Double]
    var stringValues: [String : String]

    @Relationship(deleteRule: .noAction, inverse: \Tag.events) var tags: [Tag]

    init(timestamp: Date, numericValues: [String : Double], stringValues: [String : String], tags: [Tag]) {
        self.timestamp = timestamp
        self.numericValues = numericValues
        self.stringValues = stringValues
        self.tags = tags
    }
}

@Model
final class Tag {
    var name: String
    @Relationship(deleteRule: .noAction) var events: [Event]

    init(name: String, events: [Event]) {
        self.name = name
        self.events = events
    }
}
