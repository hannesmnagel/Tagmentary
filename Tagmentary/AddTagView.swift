//
//  AddTagView.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/23/24.
//

import SwiftUI

struct AddTagView: View {
    @State private var name = String?.none
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack {
            Text("Add a new Tag")
                .font(.largeTitle.bold())
            Spacer()
            AutoCompletableField(prompt: "Name", completable: $name, suggestions: [
                .init(autoCompletable: "Sleep", info: "Track your sleep"),
                .init(autoCompletable: "Mood", info: "Learn what affects your mood"),
            ])
            .environment(\.isInitiallyFocused, true)
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                addTag()
            }
            Spacer()
            Button("Add"){
                addTag()
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .disabled(name == nil)

        }
        .padding()
        .presentationDetents([.medium, .large])
    }
    private func addTag() {
        guard let name = name else { return }
        let tag = Tag(name: name)
        modelContext.insert(tag)
        dismiss()
    }
}

#Preview {
    VStack{}
        .sheet(isPresented: .constant(true)) {
            AddTagView()
        }
}
