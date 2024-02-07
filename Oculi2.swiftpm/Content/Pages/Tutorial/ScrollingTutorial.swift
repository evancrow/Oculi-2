//
//  ScrollingTutorial.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct ScrollingTutorial: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: PaddingSizes._52) {
            ScrollView {
                LinearGradient(colors: [.blue, .red], startPoint: .top, endPoint: .bottom)
                    .frame(maxWidth: .infinity, idealHeight: 1500)
            }.followScroll(name: "tutorial", direction: .vertical)

            Button {
                onComplete()
            } label: {
                Text("Next Page")
            }
            .buttonStyle(DefaultButtonStyle())
            .onTap(name: "next") {
                onComplete()
            }
        }
    }
}

#Preview {
    ScrollingTutorial {}
}
