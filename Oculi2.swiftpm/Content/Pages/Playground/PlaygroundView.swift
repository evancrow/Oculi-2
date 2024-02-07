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
                            updateCursorSpeed(multiplier: 0.75)
                        } label: {
                            Text("Decrease")
                        }.onTap(name: "decrease") {
                            updateCursorSpeed(multiplier: 0.75)
                        }.buttonStyle(
                            DefaultButtonStyle(
                                disabled: UXDefaults.cursorMovementMultiplier.width <= 15)
                        )
                        .disabled(UXDefaults.cursorMovementMultiplier.width <= 15)

                        Spacer()

                        Button {
                            updateCursorSpeed(multiplier: 1.25)
                        } label: {
                            Text("Increase")
                        }.onTap(name: "Increase") {
                            updateCursorSpeed(multiplier: 1.25)
                        }.buttonStyle(
                            DefaultButtonStyle(
                                disabled: UXDefaults.cursorMovementMultiplier.width >= 95)
                        )
                        .disabled(UXDefaults.cursorMovementMultiplier.width >= 95)
                    }.id(updateCursorButtonState)
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
        }.padding(.bottom, geometryProxyValue.geom?.safeAreaInsets.bottom)
    }

    func updateCursorSpeed(multiplier: Double) {
        UXDefaults.cursorMovementMultiplier.apply { value in
            value * multiplier
        }
        updateCursorButtonState += 1
        print(multiplier, UXDefaults.cursorMovementMultiplier)
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
