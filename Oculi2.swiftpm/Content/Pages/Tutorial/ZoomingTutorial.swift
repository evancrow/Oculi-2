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
                    .scaleEffect(scale)
                    .scaledToFit()
                    .frame(maxWidth: UXDefaults.maximumPageWidth)
                    .clipShape(Rectangle())
                    .onZoom(
                        name: "image-zoom",
                        minZoomDepth: 0,
                        maxZoomDepth: 2,
                        scale: $scale
                    )

                Text("A cool photo I took of the Yosemite Valley!")
                    .font(FontStyles.Body2.font)
                    .italic()
            }

            VStack(spacing: PaddingSizes._12) {
                Button {
                    onComplete()
                } label: {
                    Text("Finish Tutorial")
                }
                .buttonStyle(DefaultButtonStyle())
                .onTap(name: "finish") {
                    onComplete()
                }

                Button {
                    onRestart()
                } label: {
                    Text("Restart")
                }
                .buttonStyle(UnderlinedButtonStyle())
                .onTap(name: "restart") {
                    onRestart()
                }
            }
        }
    }
}

#Preview {
    ZoomingTutorial {} onComplete: {
    }
    .environmentObject(InteractionManager())
    .environmentObject(GeometryProxyValue())
}
