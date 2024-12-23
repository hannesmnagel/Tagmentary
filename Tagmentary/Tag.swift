//
//  Tag.swift
//  Tagmentary
//
//  Created by Melanie Nagel   on 12/21/24.
//

import SwiftUI
import SwiftData

@Model
final class Tag {
    var name: String
    @Relationship(deleteRule: .noAction) var events: [Event]

    init(name: String) {
        self.name = name
        self.events = []
    }
}
