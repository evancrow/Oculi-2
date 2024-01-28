//
//  PageContainer.swift
//  
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct PageContainer<Content: View>: View {
    let content: Content
    
    var body: some View {
        content.padding(52)
    }
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

#Preview {
    PageContainer {
        EmptyView()
    }
}
