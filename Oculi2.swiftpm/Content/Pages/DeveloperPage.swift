//
//  DeveloperPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct DeveloperPage: View {
    @EnvironmentObject var navigationModel: NavigationModel

    var body: some View {
        PageContainer {
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._12) {
                    Text("How Developers Use Oculi")
                        .font(FontStyles.Title.font)

                    Text(
                        "This is how developers or Apple can add Oculi to their SwiftUI applications."
                    )
                    .font(FontStyles.Body.font)
                }

                Button {
                    navigationModel.moveToNextPage()
                } label: {
                    Text("Return to Playground")
                }.buttonStyle(DefaultButtonStyle())
            }
        }
    }
}

#Preview {
    DeveloperPage()
}
