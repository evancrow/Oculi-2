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
    @Binding var selectedOption: String
    let options: [String]
    var showSelected: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    selectedOption = option
                } label: {
                    Text(option)
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
}

#Preview {
    SegmentedPicker(
        selectedOption: .constant("One"),
        options: [
            "One",
            "Two",
            "Three",
        ]
    )
}
