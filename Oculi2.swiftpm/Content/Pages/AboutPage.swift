//
//  AboutPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct AboutPage: View {
    @EnvironmentObject var navigationModel: NavigationModel

    var body: some View {
        PageContainer {
            VStack(spacing: 52) {
                Text("An Introduction")
                    .font(FontStyles.Title.font)

                TextSection(
                    header: "What",
                    text:
                        "Oculi is an innovative accessibility software created by me, Evan Crow! It gives individuals with motor impairments new ways to interact with their Apple devices."
                )

                TextSection(
                    header: "How",
                    text:
                        "Magic 🪄! But also, Apple Vision, Machine Learning, and some basic algebra."
                )

                TextSection(
                    header: "And This?",
                    text:
                        "This app is a demonstration of Oculi's capabilities. Oculi 2 will (soon) be an open source library that any developer (or Apple) can easily add to their SwiftUI app."
                )

                TextSection(
                    header: "Inspiration",
                    text:
                        "Oculi 1 began with my heartfelt conversations with individuals who have motor impairments over two years ago. With the advent of Apple Vision Pro and ongoing dialogues with the disability community, the spark for Oculi 2 was ignited. This new version introduces hand-tracking technology, enabling users to interact with their devices from afar – eliminating the need to physically move or get up. No remote needed.\n\nOculi 2 is more than an accessibility tool; it's a commitment to making technology inclusive and empowering for everyone."
                )

                Button {
                    navigationModel.moveToNextPage()
                } label: {
                    Text("Set Up")
                }.buttonStyle(DefaultButtonStyle())
            }
        }
    }
}

#Preview {
    AboutPage()
}
