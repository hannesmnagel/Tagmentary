//
//  EnumPickerView.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/24/24.
//

import SwiftUI

protocol EnumPickable: CaseIterable, Hashable, RawRepresentable<String> {
    var symbolName: String? { get }
}

struct EnumPickerView<Value: EnumPickable>: View {
    let title: String
    @Binding var value: Value
    let cases: [Value]

    init(_ title : String = "", value: Binding<Value>) {
        self.title = title
        self._value = value
        self.cases = Value.allCases as! [Value]
    }

    var body: some View {
        Picker(title, selection: $value) {
            ForEach(cases, id: \.self){valueCase in
                if let symbolName = valueCase.symbolName {
                    Label(valueCase.rawValue, systemImage: symbolName)
                } else {
                    Text(valueCase.rawValue)
                }
            }
        }
    }
}

#Preview {
    enum TestEnum: String, EnumPickable {
        var symbolName: String? {
            switch self {
            case .case1: return "plus"
            case .case2: return "minus"
            }
        }

        case case1
        case case2
    }
    @Previewable @State var selection = TestEnum.case1
    return EnumPickerView("Test", value: $selection).pickerStyle(.segmented)
}
#Preview {
    enum TestEnum: String, EnumPickable {
        var symbolName: String? {
            switch self {
            case .case1: return "plus"
            case .case2: return "minus"
            }
        }
        case case1
        case case2
    }
    @Previewable @State var selection = TestEnum.case1
    return Form{EnumPickerView("Test", value: $selection)}
}
