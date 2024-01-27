//
//  SectionPage.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import SwiftUI

struct SectionPage<Title: View, Content: View>: View {
    let title: Title
    let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                title
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
        }.padding(24)
    }
    
    init(@ViewBuilder title: () -> Title, @ViewBuilder content: () -> Content) {
        self.title = title()
        self.content = content()
    }
}

#Preview {
    SectionPage {
        Text("Title")
    } content: {
        EmptyView()
    }
}
