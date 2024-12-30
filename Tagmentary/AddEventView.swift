//
//  AddEventView.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/23/24.
//

import SwiftUI
import SwiftData

struct AddEventView: View {
    @Query private var tags: [Tag]
    @State private var associatedTag = Tag?.none
    @State private var date = Date()
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var value = 0.0
    @State private var presentation = PresentationDetent.medium
    @FocusState private var focusState

    var body: some View{
        ViewThatFits{
            content
            ScrollView{
                content
            }
        }
    }
    @ViewBuilder
    var content: some View {
        VStack {
            Text("Add an Event")
                .font(.largeTitle.bold())
            Spacer()
            DatePicker("Date", selection: $date, displayedComponents: .date)

            Spacer()
            Text("Tags")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            ScrollView(.horizontal){
                LazyHGrid(rows: [
                    GridItem(.adaptive(minimum: 35, maximum: 35))
                ]){
                    ForEach(tags){tag in
                        Button{
                            associatedTag = tag
                            UserDefaults.standard.set(tag.name, forKey: "lastAddedTag")
                        } label: {
                            Text(tag.name)
                                .frame(maxWidth: .infinity)
                                .padding(2)
                        }
                        .foregroundStyle(associatedTag == tag ? Color.accentColor : .gray)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .padding(2)
                    }
                }
            }
            .scrollClipDisabled()
            .containerRelativeFrame(.vertical) { len, _ in
                switch tags.count {
                case 0...5:
                    len/8
                    case 6...10:
                    len/5
                default:
                    len/3
                }
            }
            .onAppear{
                let lastAddedTag = UserDefaults.standard.string(forKey: "lastAddedTag")
                if let tag = tags.first(where: {$0.name == lastAddedTag}) {
                    associatedTag = tag
                }
            }

            Spacer()
            Text("Value")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            TextField("Value", value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
            Spacer()
            Button("Add") {
                addEvent()
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .padding()
        .presentationDetents([.medium, .large], selection: $presentation)
    }
    private func addEvent() {
        guard let associatedTag else { return }
        let event = Event(timestamp: date, tag: associatedTag, value: value)
        modelContext.insert(event)
        dismiss()
    }
}

#Preview {
    VStack{}
        .sheet(isPresented: .constant(true)) {
            AddEventView()
        }
}


extension String {
    var optional: String? {
        get {self} set {self = newValue ?? ""}
    }
}
