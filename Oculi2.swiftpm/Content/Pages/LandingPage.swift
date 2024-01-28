//
//  LandingPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct LandingPage: View {
    @EnvironmentObject var navigationModel: NavigationModel

    var body: some View {
        PageContainer {
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._6) {
                    Text("Welcome to Oculi")
                        .font(FontStyles.Title.font)

                    Text("AN ACCESSIBILITY TOOL BY EVAN CROW — VERSION 2")
                        .font(FontStyles.Body2.font)
                }

                Button {
                    navigationModel.moveToNextPage()
                } label: {
                    Text("Get Started")
                }.buttonStyle(DefaultButtonStyle())
            }
        }
    }
}

#Preview {
    LandingPage()
}
