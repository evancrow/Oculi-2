//
//  PlaygroundPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct PlaygroundPage: View {
    @EnvironmentObject var navigationModel: NavigationModel

    var body: some View {
        PageContainer {
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._52) {
                    VStack(spacing: PaddingSizes._6) {
                        Text("Playground")
                            .font(FontStyles.Title.font)

                        Text("Here you can try interacting with different elements.")
                            .font(FontStyles.Body.font)
                    }

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
                }

                Spacer()

                HStack(spacing: PaddingSizes._52) {
                    Button {
                        navigationModel.stack(page: .Calibrate)
                    } label: {
                        Text("Calibrate")
                    }

                    Button {
                        navigationModel.stack(page: .Tutorial)
                    } label: {
                        Text("Tutorial")
                    }

                    Button {
                        navigationModel.goTo(page: .Developer)
                    } label: {
                        Text("How Developers Use Oculi")
                    }

                    Button {
                        navigationModel.goTo(page: .EvanCrow)
                    } label: {
                        Text("Evan Crow")
                    }
                }.buttonStyle(UnderlinedButtonStyle())
            }
        }
    }
}

#Preview {
    PlaygroundPage()
}
