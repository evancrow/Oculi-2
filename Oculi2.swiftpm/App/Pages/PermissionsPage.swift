//
//  PermissionsPage.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import SwiftUI

struct PermissionsPage: View {
    var body: some View {
        SectionPage(italicTitle: "", titleEnd: "Permissions") {
            HStack {
                Text("Oculi needs access to your Camera, Microphone, and Speech Recoginition. This enables the magical features ✨ Oculi introduces.")
                
                Spacer()
            }
            
            Button {
                
            } label: {
                Text("Get Started")
            }.buttonStyle(FilledButtonStyle())
        }
    }
}

#Preview {
    PermissionsPage()
}
