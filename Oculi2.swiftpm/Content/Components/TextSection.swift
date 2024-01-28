//
//  TextSection.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct TextSection: View {
    let header: String
    let text: String
    let expandedSize: Bool

    var body: some View {
        HStack(
            alignment: expandedSize ? .top : .center,
            spacing: expandedSize ? PaddingSizes._32 : PaddingSizes._12
        ) {
            Text(header)
                .font(FontStyles.Title3.font)
                .frame(maxWidth: expandedSize ? 100 : nil)
                .multilineTextAlignment(.center)

            Text(text)
                .font(FontStyles.Body.font)
                .frame(maxWidth: expandedSize ? 500 : nil, alignment: .leading)
        }
    }

    init(header: String, text: String, expandedSize: Bool = true) {
        self.header = header
        self.text = text
        self.expandedSize = expandedSize
    }
}

#Preview {
    VStack(spacing: 32) {
        TextSection(header: "Line 1", text: "Text line.")
        TextSection(header: "Line 2", text: "Text line.")
        TextSection(header: "Header", text: "Text\nNew line.")

        TextSection(header: "Header", text: "Text", expandedSize: false)
    }
}
