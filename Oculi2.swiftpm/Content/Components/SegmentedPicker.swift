//
//  SegmentedPicker.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct SegmentedPickerOption: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let onPick: () -> Void
    
    static func == (lhs: SegmentedPickerOption, rhs: SegmentedPickerOption) -> Bool {
        lhs.id == rhs.id
    }
}

struct SegmentedPicker: View {
    @State var selectedOption: SegmentedPickerOption
    let showSelected: Bool
    let options: [SegmentedPickerOption]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options) { option in
                Button {
                    selectedOption = option
                    option.onPick()
                } label: {
                    Text(option.label)
                        .padding(.horizontal, PaddingSizes._32)
                        .padding(.vertical, PaddingSizes._12)
                        .frame(maxHeight: .infinity)
                        .background(
                            selectedOption == option && showSelected ? Color.Oculi.Pink : nil
                        )
                }.buttonStyle(UnderlinedButtonStyle())
            }
        }
        .background(
            Color(uiColor: .systemGroupedBackground)
        )
        .fixedSize(horizontal: false, vertical: true)
    }
    
    init(showSelected: Bool = true, options: [SegmentedPickerOption]) {
        self._selectedOption = .init(initialValue: options[0])
        self.showSelected = showSelected
        self.options = options
    }
}

#Preview {
    SegmentedPicker(
        options: [
            .init(label: "One", onPick: {}),
            .init(label: "Two", onPick: {}),
            .init(label: "Three", onPick: {}),
        ]
    )
}
