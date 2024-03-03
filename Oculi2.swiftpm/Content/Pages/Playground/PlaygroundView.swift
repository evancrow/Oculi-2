//
//  PlaygroundView.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct PlaygroundView: View {
    @EnvironmentObject var geometryProxyValue: GeometryProxyValue
    @State var screenBrightness: CGFloat
    @State var name: String = ""
    @State var updateCursorButtonState = 0

    var body: some View {
        HStack {
            Spacer()

            VStack(spacing: PaddingSizes._52) {
                TextSection(
                    header: "Thank You",
                    text:
                        "This is the last page of the Oculi demo. Thank you for trying it out, I appreciate your time and consideration!"
                )

                VStack(alignment: .leading, spacing: PaddingSizes._12) {
                    Text("Screen Brightness")
                        .font(FontStyles.Body.font)

                    Slider(value: $screenBrightness)
                }.onChange(of: screenBrightness) { value in
                    UIScreen.main.brightness = value
                }

                VStack(alignment: .leading, spacing: PaddingSizes._12) {
                    Text("Artboard")
                        .font(FontStyles.Body.font)

                    ArtboardView()
                }
            }
            .font(FontStyles.Body.font)
            .frame(maxWidth: UXDefaults.maximumPageWidth)

            Spacer()
        }
    }

    init() {
        self.screenBrightness = UIScreen.main.brightness
    }
}

#Preview {
    GeometryReader { geom in
        PlaygroundView()
            .environmentObject(GeometryProxyValue(geom: geom))
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}
