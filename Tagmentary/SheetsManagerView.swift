//
//  SheetsManagerView.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/23/24.
//

import SwiftUI
import SwiftData

struct SheetsManagerView: View {
    @AppStorage("showingAddTag") private var showingAddTag = false
    @AppStorage("showingAddEvent") private var showingAddEvent = false
    @AppStorage("showingSettings") private var showingSettings = false
    @AppStorage("showingEvents") private var showingEvents = false
    @Query private var tags: [Tag]
    @Environment(\.modelContext) var modelContext
    let yAxis: Set<Tag>

    var body: some View {
        VStack{}
            .sheet(isPresented: $showingAddTag) {
                AddTagView()
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingEvents) {
                Text("Events")
                    .font(.largeTitle.bold())
                    .padding(.top)
                listView
            }
    }

    @ViewBuilder
    var listView: some View {
        let events = tags.filter{yAxis.contains($0)}.flatMap{$0.events}.sorted(by: {$0.timestamp > $1.timestamp})
        List{
            ForEach(events) {event in
                HStack{
                    Text(event.tag.name)
                    Spacer()
                    Text(event.value, format: .number.precision(.fractionLength(2)))
                        .padding(.trailing, 5)
                    Text(event.timestamp, format: .dateTime.day().month())
                }
            }
            .onDelete { indexset in
                indexset.forEach{
                    modelContext.delete( events[$0] )
                }
            }
        }
    }
}

#Preview {
    SheetsManagerView(yAxis: [])
}
