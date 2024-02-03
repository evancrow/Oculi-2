//
//  ZoomingTutorial.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct ZoomingTutorial: View {
    @State private var scale: Double = 1

    let onRestart: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: PaddingSizes._52) {
            VStack(spacing: PaddingSizes._12) {
                Image("Yosemite")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)

                Text("A cool photo I took of the Yosemite Valley!")
                    .font(FontStyles.Body2.font)
                    .italic()
            }
            .clipShape(Rectangle())
            .frame(maxWidth: 500)

            VStack(spacing: PaddingSizes._12) {
                Button {
                    onComplete()
                } label: {
                    Text("Finish Tutorial")
                }.buttonStyle(DefaultButtonStyle())

                Button {
                    onRestart()
                } label: {
                    Text("Restart")
                }.buttonStyle(UnderlinedButtonStyle())
            }
        }
    }
}

#Preview {
    ZoomingTutorial {
    } onComplete: {
    }
}
