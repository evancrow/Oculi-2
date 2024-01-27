//
//  File.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import Foundation
import SwiftUI

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Group {
            configuration.label
        }
        .padding()
        .padding(.horizontal)
        .foregroundStyle(Color.white)
        .background(Color.accentColor.opacity(configuration.isPressed ? 0.8 : 1))
        .clipShape(Capsule())
    }
}

#Preview {
    Button {
        // Preview button label.
    } label: {
        Text("Preview")
    }.buttonStyle(FilledButtonStyle())
}
