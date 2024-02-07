//
//  DictationField.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct DictationField: View {
    @EnvironmentObject private var interactionManager: InteractionManager
    @EnvironmentObject private var speechRecognizerModel: SpeechRecognizerModel

    let placeholder: String
    @Binding var text: String
    @FocusState var focusTextField: Bool
    @State var unfocusFieldTimer: Timer?

    // Microphone aniamtion
    /// Either 0 or 1, both will have a different effect.
    @State var microphoneAnimationState: Int = 0
    @State var animationTimer: Timer?

    var id: String {
        return placeholder
    }

    var speechRecognizerIsActive: Bool {
        focusTextField && speechRecognizerModel.isListening
    }

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .focused($focusTextField)
                .padding(PaddingSizes._22)
                .background(Color.Oculi.Pink)
                .foregroundStyle(Color.Oculi.Button.Label)
                .onTap(name: placeholder) {
                    focusTextField = true
                }.onChange(of: focusTextField) { newValue in
                    if focusTextField {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            speechRecognizerModel.startListening(with: id)
                        }
                    } else {
                        speechRecognizerModel.stopListening(with: id)
                    }
                }.onChange(of: speechRecognizerModel.isListening) { _ in
                    if speechRecognizerIsActive {
                        animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                            _ in
                            withAnimation {
                                microphoneAnimationState = (microphoneAnimationState == 0 ? 1 : 0)
                            }
                        }
                    } else {
                        animationTimer?.invalidate()
                        animationTimer = nil
                        microphoneAnimationState = 0
                    }
                }.onChange(of: speechRecognizerModel.transcript) { transcript in
                    guard let transcriptForTextField = transcript[id] else {
                        return
                    }

                    self.text = transcriptForTextField
                    
                    unfocusFieldTimer?.invalidate()
                    unfocusFieldTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                        focusTextField = false
                    }
                }

            if speechRecognizerIsActive {
                Image(systemName: "waveform.and.mic")
                    .foregroundColor(
                        microphoneAnimationState == 0 ? Color(uiColor: .label) : .Oculi.Pink
                    )
            }
        }
    }
}

struct DictationFieldView_Previews: PreviewProvider {
    static var previews: some View {
        DictationField(placeholder: "Placeholder", text: .constant(""))
            .environmentObject(GeometryProxyValue())
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}
