//
//  PlaygroundView.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct PlaygroundView: View {
    @State var screenBrightness: CGFloat
    @State var name: String = ""

    var body: some View {
        HStack {
            Spacer()

            VStack(spacing: PaddingSizes._52) {
                TextSection(
                    header: "Thank You",
                    text:
                        "This is the last page of the Oculi demo. Thank you for trying it out, I appreciate your time and consideration!"
                )

                TextSection(
                    header: "Tip",
                    text:
                        "You can always re-calibrate or restart the tutorial by tapping the options at the bottom of the page."
                )

                VStack(alignment: .leading, spacing: PaddingSizes._12) {
                    Text("Screen Brightness")
                    Slider(value: $screenBrightness)
                }.onChange(of: screenBrightness) { value in
                    UIScreen.main.brightness = value
                }

                VStack(alignment: .leading, spacing: PaddingSizes._12) {
                    Text("Cursor Speed")

                    HStack {
                        Button {

                        } label: {
                            Text("Decrease")
                        }

                        Spacer()

                        Button {

                        } label: {
                            Text("Increase")
                        }
                    }.buttonStyle(DefaultButtonStyle())
                }

                VStack(alignment: .leading, spacing: PaddingSizes._12) {
                    Text("Speech Recognition")
                    if !name.isEmpty {
                        Text("Hey, \(name)!")
                    }
                    DictationField(placeholder: "Your name", text: $name)
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
