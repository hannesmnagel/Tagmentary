//
//  Detail.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/23/24.
//

import Foundation


enum Detail: String, Hashable, Codable, Equatable, CaseIterable, RawRepresentable {
    case day, month

    var calendarRepresentation: Calendar.Component {
        switch self {
        case .day: return .day
        case .month: return .month
        }
    }
}
