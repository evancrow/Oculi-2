//
//  ButtonStyles.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import Foundation
import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
    var disabled = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontStyles.Title3.font)
            .padding(.horizontal, 75)
            .padding(.vertical, 18)
            .background(Color.Oculi.Pink)
            .foregroundStyle(Color.Oculi.Button.Label)
            .opacity(configuration.isPressed || disabled ? 0.7 : 1)
    }
}

struct UnderlinedButtonStyle: ButtonStyle {
    var disabled = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontStyles.Header2.font)
            .underline()
            .italic()
            .opacity(configuration.isPressed || disabled ? 0.7 : 1)
    }
}

#Preview {
    VStack(spacing: 32) {
        Button {

        } label: {
            Text("Button Label")
        }.buttonStyle(DefaultButtonStyle())

        Button {

        } label: {
            Text("Button Label")
        }.buttonStyle(UnderlinedButtonStyle())
    }
}
