//
//  ImpactView.swift
//
//
//  Created by Evan Crow on 2/8/24.
//

import SwiftUI

struct ImpactView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PaddingSizes._52) {
                TextSection(
                    header: "Use Cases",
                    text:
                        "This is a breakthrough for individuals with limited mobility, such as those who cannot use their arms or struggle to reach and interact with devices. It's especially useful for people like my mom, who finds it difficult to get up and operate her device. With Oculi, simple facial or hand gestures bring the world to their fingertips, offering independence and ease."
                )

                TextSection(
                    header: "Impact",
                    text:
                        "Everyday tasks simpler and more enjoyable. Oculi is particularly impactful for individuals who need an alternative way to interact with their devices, enhancing their ability to connect, learn, and be entertained without physical barriers."
                )

                TextSection(
                    header: "Room for Growth",
                    text:
                        "There's always potential to expand Oculi's capabilities, like multi-user support to cater to different family members' needs. Or enhancing features like pinch-to-zoom could further enrich the user experience."
                )
            }
        }.followScroll(name: "impact", direction: .vertical)
    }
}

#Preview {
    GeometryReader { geom in
        ImpactView()
            .environmentObject(GeometryProxyValue(geom: geom))
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}
