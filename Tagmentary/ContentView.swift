//
//  ContentView.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/21/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tags: [Tag]

    var body: some View {
        NavigationSplitView {
            ScrollView{
                LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: 300))]) {
                    ForEach(tags) { tag in
                        NavigationLink {
                            TagDetailView(tag: tag)
                        } label: {
                            TagOverview(tag: tag)
                        }
                        .contextMenu {
                            Button(
                                "Delete Tag \(tag.name)",
                                systemImage: "trash",
                                role: .destructive
                            ){
                                modelContext.delete(tag)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                Button("Delete All", systemImage: "trash", role: .destructive){
                    try? modelContext.delete(model: Event.self)
                    try? modelContext.delete(model: Tag.self)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let tag = Tag(name: "New Tag")
            modelContext.insert(tag)
            tag.events = [
                Event(timestamp: .now, numericValues: [.init(key: "num", value: .random(in: 0...5))]),
                Event(timestamp: .now-3600*24, numericValues: [.init(key: "num", value: .random(in: 0...5))])
            ].map {
                modelContext.insert($0)
                return $0
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tags[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Event.self, inMemory: true)
}


