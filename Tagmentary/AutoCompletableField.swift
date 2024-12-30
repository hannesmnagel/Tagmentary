//
//  AutoCompletableField.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/23/24.
//

import SwiftUI

struct AutoCompleteSuggestion<Value: AutoCompletable>{
    let autoCompletable: Value
    let info: String
}

extension EnvironmentValues {
    @Entry var isInitiallyFocused = false
}

struct AutoCompletableField<Value: AutoCompletable>: View {
    @Environment(\.isInitiallyFocused) var isInitiallyFocused
    let prompt: LocalizedStringKey
    @Binding var completable: Value?
    let suggestions: [AutoCompleteSuggestion<Value>]

    @State private var text: String

    @FocusState private var isFocused

    init(prompt: LocalizedStringKey, completable: Binding<Value?>, suggestions: [AutoCompleteSuggestion<Value>]) {
        self.prompt = prompt
        self._completable = completable
        self.suggestions = suggestions
        self.text = completable.wrappedValue?.autoCompletion ?? ""
    }

    var body: some View {
        TextField(prompt, text: $text)
            .focused($isFocused)
            .onAppear{
                isFocused = isInitiallyFocused
            }
            .onChange(of: text) {
                if let value = text as? Value {
                    completable = value
                }
                if let suggestion = suggestions.first(where: {$0.autoCompletable.autoCompletion.lowercased() == text.lowercased()}) {
                    completable = suggestion.autoCompletable
                }
            }
        VStack{
            if isFocused {
                let suggestionsToDisplay = suggestions.filter({
                    $0.autoCompletable.autoCompletion.localizedCaseInsensitiveContains(text) && $0.autoCompletable != completable
                }).prefix(5)
                if !suggestionsToDisplay.isEmpty {
                    List(suggestionsToDisplay, id: \.autoCompletable.autoCompletion) { suggestion in
                        Button{
                            text = suggestion.autoCompletable.autoCompletion
                            completable = suggestion.autoCompletable
                        } label: {
                            Text(suggestion.autoCompletable.autoCompletion)
                                .bold()
                            Text(suggestion.info)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                    }
                    .listStyle(.plain)
                    .transition(.scale)
                }
            }
        }
        .animation(.smooth, value: isFocused)
        .animation(.smooth, value: text)
    }
}

#Preview {
    @Previewable @State var text = String?.none
    AutoCompletableField(prompt: "Start typing...", completable: $text, suggestions: [
        .init(autoCompletable: "Hello", info: "Greeting"),
        .init(autoCompletable: "Red", info: "A color"),
        .init(autoCompletable: "Big", info: "Also large"),
    ])
}
