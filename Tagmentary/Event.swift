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
    var numericValues: [NumericValue]

    @Relationship(deleteRule: .noAction, inverse: \Tag.events) var tags: [Tag]

    init(timestamp: Date, numericValues: [NumericValue]) {
        self.timestamp = timestamp
        self.numericValues = numericValues
        self.tags = []
    }
    struct NumericValue: Codable, Hashable {
        var key: String
        var value: Double
    }
}

