//
//  TagOverview.swift
//  Tagmentary
//
//  Created by Melanie Nagel   on 12/21/24.
//


import SwiftUI
import Charts

struct TagOverview: View {
    let tag: Tag
    var body: some View {
        let events = tag.events.sorted{
            $0.timestamp < $1.timestamp
        }.filter({
            Calendar.current.isDate(
                .now,
                equalTo: $0.timestamp,
                toGranularity: .weekOfYear
            )
        })
        let _ = Self._printChanges()
        VStack{
            Text(tag.name)
                .padding()
            if !events.isEmpty {
                Chart {
                    ForEach(events){ event in
                        LineMark(
                            x: .value("Type", event.timestamp),
                            y: .value("Value", event.numericValues.first!.key)
                        )
                    }
                }
                .chartXScale(domain: events.first!.timestamp...events.last!.timestamp)
            } else {
                Text("No recent events")
            }
        }
        .padding()
        .overlay{
            RoundedRectangle(cornerRadius: 20)
                .stroke()
        }
    }
}


#Preview {
    TagOverview(
        tag: Tag(
            name: "Tag"
        )
    )
    .frame(width: 150, height: 150)
}
