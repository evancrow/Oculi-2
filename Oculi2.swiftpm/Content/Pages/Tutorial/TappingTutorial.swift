//
//  TappingTutorial.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct TappingTutorial: View {
    @State private var oneTap = false
    @State private var twoTap = false
    @State private var longTap = false

    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: PaddingSizes._52) {
            Button {
                oneTap.toggle()
            } label: {
                Text(oneTap ? "Tap - Tapped!" : "Tap")
            }
            .buttonStyle(DefaultButtonStyle())
            .onTap(name: "tap") {
                oneTap.toggle()
            }

            Button {
                twoTap.toggle()
            } label: {
                Text(twoTap ? "Two Taps - Tapped!" : "Two Taps")
            }
            .buttonStyle(DefaultButtonStyle())
            .onTap(name: "two-taps") {
                twoTap.toggle()
            }

            Button {
                longTap.toggle()
            } label: {
                Text(longTap ? "Long Tap - Tapped!" : "Long Tap")
            }
            .buttonStyle(DefaultButtonStyle())
            .onLongTap(name: "long-tap") {
                longTap.toggle()
            }

            Button {
                onComplete()
            } label: {
                Text("Next Page")
            }.buttonStyle(DefaultButtonStyle())
        }
    }
}

#Preview {
    TappingTutorial {}
}
