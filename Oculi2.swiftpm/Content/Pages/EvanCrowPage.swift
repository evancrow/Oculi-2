//
//  EvanCrowPage.swift
//  
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct EvanCrowPage: View {
    @EnvironmentObject var navigationModel: NavigationModel
    
    var body: some View {
        PageContainer {
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._12) {
                    Text("Evan Crow")
                        .font(FontStyles.Title.font)
                    
                    Text("Behind the creator.")
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
    EvanCrowPage()
}
