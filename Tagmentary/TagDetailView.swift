//
//  TagDetailView.swift
//  Tagmentary
//
//  Created by Hannes Nagel   on 12/21/24.
//

import SwiftUI
import SwiftData
import Charts

struct TagDetailView: View {
    let tag: Tag

    var body: some View {
        Text(tag.name)
        let events = tag.events
        Chart{
            ForEach(events) { event in
                ForEach(event.numericValues, id: \.self) { numericValue in
                    LineMark(
                        x: .value("timestamp", event.timestamp),
                        y: .value("key", numericValue.key),
                        series: .value("series", numericValue.value)
                    )
                    .foregroundStyle(by: .value("series", numericValue.key))
                }
            }
        }
    }
}


#Preview {
    let tag = Tag(name: "New Tag")
    let _ = {
        tag.events = [
            Event(
                timestamp: .now,
                numericValues: [.init(key: "num", value: .random(in: 0...5))]
            ),
            Event(
                timestamp: .now-3600*24,
                numericValues: [.init(key: "num", value: .random(in: 0...5))]
            )
        ]
    }()
    TagDetailView(tag: tag)
}
