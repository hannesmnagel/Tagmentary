//
//  ContentView.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/21/24.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tags: [Tag]
    @Query(sort: \Event.timestamp) private var events: [Event]
    @AppStorage("showingAddTag") private var showingAddTag = false
    @AppStorage("showingAddEvent") private var showingAddEvent = false
    @AppStorage("showingEvents") private var showingEvents = false
    @AppStorage("showingSettings") private var showingSettings = false
    @AppStorage("xAxisZoom") private var xAxisZoom = 10.0
    @State private var yAxis = Set<Tag>()
    @State private var xAxis : Tag?

    var body: some View {
        VStack{
            SheetsManagerView(yAxis: yAxis)
                .onAppear {
                    xAxis = tags.first
                    yAxis = Set(tags.dropFirst())
                }
            tagPicker

            if tags.isEmpty {
                ContentUnavailableView("No Tags", systemImage: "mappin.circle", description: Text("Add some Tags or configure automatic sleep imports in Settings"))
            } else {
                chart
                    .overlay(alignment: .leading){
                        HStack{
                            Text("<- ")
                            if yAxis.isEmpty {
                                Text("Select a Tag to show")
                            }
                            Text(Array(yAxis.map{String($0.name.prefix(10))}.prefix(4)), format: .list(type: .and)) + Text(yAxis.count > 4 ? ", ..." : "")
                            Text("->")
                        }
                        .font(.system(size: 10))
                        .fixedSize()
                        .compositingGroup()
                        .rotationEffect(.degrees(-90))
                        .frame(width: 20)
                    }
                    .overlay{
                        if events.isEmpty {
                            ContentUnavailableView("No Events", systemImage: "mappin.circle", description: Text("Add Events to track anything and their effects on each other"))
                        }
                    }
                HStack{
                    Text(" <- ")
                    Text(xAxis?.name ?? "Select a Tag to show")
                    Text(" -> ")
                }
                .font(.system(size: 10))
                .padding(.bottom)

                VStack{
                    Button("Events"){
                        showingEvents = true
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .background()
                    .clipShape(.capsule)
                    Button("Add Event", systemImage: "plus"){
                        showingAddEvent = true
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .background()
                    .clipShape(.capsule)
                }
            }
        }
        .animation(.smooth, value: events)
        .animation(.smooth, value: tags)
        .animation(.smooth, value: yAxis)
    }
    var chart: some View {
        Chart{
            ForEach(events.filter{yAxis.contains($0.tag) && !$0.isDeleted}) {event in
                let xValues = xAxisForDate(for: event.timestamp)
                ForEach(xValues, id: \.self) {value in
                    PointMark(
                        x: .value("value", value),
                        y: .value("value", event.value)
                    )
                    .foregroundStyle(by: .value("color", event.tag.name))
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXScale(domain: .automatic(includesZero: false))
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXVisibleDomain(length: xAxisZoom)
    }
    func xAxisForDate(for date: Date) -> [Double] {
        let events = xAxis?.events.filter{Calendar.current.isDate($0.timestamp, inSameDayAs: date)}
        return events?.map{$0.value} ?? []
    }

    private enum TagState { case x,y,none }

    @ViewBuilder
    var tagPicker: some View {
        VStack {
            HStack{
                Button{
                    showingAddTag = true
                } label: {
                    Text("Add Tag")
                        .padding(2)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .frame(maxWidth: .infinity, alignment: .leading)

                if let xAxis {
                    Button{
                        yAxis.insert(xAxis)
                        self.xAxis = nil
                    } label: {
                        HStack{
                            Image(systemName: "xmark")
                            Text(xAxis.name)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    Spacer()
                }

                Button{
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .padding(2)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 10)
            if !tags.isEmpty {
                if xAxis == nil {
                    Text("Select a Tag to show on the X axis")
                        .padding(.top)
                } else if yAxis.isEmpty {
                    Text("Select Tags to compare to")
                        .padding(.top)
                }
                ScrollView(.horizontal){
                    HStack{
                        if let xAxis, !tags.isEmpty{
                            Button{
                                if yAxis.isEmpty {
                                    yAxis = Set(tags).subtracting(Set([xAxis]))
                                } else {
                                    yAxis.removeAll()
                                }
                            } label: {
                                Text(yAxis.isEmpty ? "All" : "None")
                                    .frame(maxWidth: .infinity)
                                    .padding(2)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .padding(2)
                        }
                        ForEach(tags.filter{$0 != xAxis}){tag in
                            let tagState : TagState = xAxis == tag ? .x : yAxis.contains(tag) ? .y : .none
                            Button{
                                if xAxis == nil {
                                    yAxis.remove(tag)
                                    xAxis = tag
                                } else if yAxis.contains(tag) {
                                    yAxis.remove(tag)
                                } else {
                                    yAxis.insert(tag)
                                }
                            } label: {
                                HStack{
                                    Text(tag.name)
                                    if xAxis != nil {
                                        Spacer()
                                        Text(tagState == .x ? "X" : tagState == .y ? "Y" : "")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(2)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .padding(2)
                            .contextMenu{
                                Button("Delete", systemImage: "trash", role: .destructive){
                                    yAxis.remove(tag)
                                    if xAxis == tag { xAxis = nil }
                                    modelContext.delete(tag)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
            }
        }
        .animation(.spring, value: xAxis)
        .animation(.spring, value: yAxis)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Event.self, inMemory: true)
}


