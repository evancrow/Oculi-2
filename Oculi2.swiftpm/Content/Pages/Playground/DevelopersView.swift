//
//  DevelopersView.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct DevelopersView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: PaddingSizes._52) {
            VStack(alignment: .leading, spacing: PaddingSizes._12) {
                VStack(alignment: .leading, spacing: PaddingSizes._6) {
                    Text("Step 1")
                        .font(FontStyles.Header.font)

                    Text("Wrap your content in an ").font(FontStyles.Body.font)
                        + Text("InteractionViewWrapper").font(FontStyles.Code.font)

                }

                let codeSnippet = """
                    @main
                    struct MyApp: App {
                        var body: some Scene {
                            WindowGroup {
                                InteractionViewWrapper {
                                    ContentView()
                                }
                            }
                        }
                    }
                    """

                Text(codeSnippet)
                    .font(FontStyles.Code.font)
            }

            VStack(alignment: .leading, spacing: PaddingSizes._6) {
                Text("Step 2")
                    .font(FontStyles.Header.font)

                Text(
                    "Setup complete! Oculi automatically handles calibration and permissions for you. Easily add support for a variety of interactions, with "
                ) + Text("onTap").font(FontStyles.Code.font) + Text(", ")
                    + Text("onLongTap").font(FontStyles.Code.font) + Text(", ")
                    + Text("onDrag").font(FontStyles.Code.font) + Text(", and ")
                    + Text("onZoom").font(FontStyles.Code.font) + Text(".")
            }.font(FontStyles.Body.font)
        }.frame(maxWidth: 600)
    }
}

#Preview {
    DevelopersView()
}