//
//  ChartStyle.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/24/24.
//

import Foundation


enum ChartStyle: String, EnumPickable, Codable {
    var symbolName: String? {
        switch self {
        case .bar: return "chart.bar.xaxis"
        case .line: return "chart.xyaxis.line"
        }
    }

    case bar = "Bar Chart"
    case line = "Line Chart"
}
