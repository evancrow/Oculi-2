//
//  Popup.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct Popup<Content: View>: View {
    @Binding private var expanded: Bool
    let staticState: Bool
    let collapsedIcon: String?
    let content: Content

    var body: some View {
        VStack(spacing: PaddingSizes._32) {
            if expanded {
                content

                if !staticState {
                    Button(action: toggleExpandedState) {
                        Text("Close")
                    }
                    .buttonStyle(UnderlinedButtonStyle())
                    .onLongTap(name: "Close", action: toggleExpandedState)
                }
            } else {
                Button(action: toggleExpandedState) {
                    Image(systemName: collapsedIcon ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    
                }
                .onLongTap(name: "Expand", action: toggleExpandedState)
            }
        }
        .padding(expanded ? PaddingSizes._32 : PaddingSizes._12)
        .foregroundStyle(Color.Oculi.Button.Label)
        .background(Color.Oculi.Pink)
        .clipShape(RoundedRectangle(cornerRadius: expanded ? 0 : .infinity))
    }

    func toggleExpandedState() {
        if !staticState {
            withAnimation(.interactiveSpring) {
                expanded.toggle()
            }
        }
    }

    init(
        expanded: Binding<Bool>,
        collapsedIcon: String,
        @ViewBuilder content: () -> Content
    ) {
        self._expanded = expanded
        self.staticState = false
        self.collapsedIcon = collapsedIcon
        self.content = content()
    }

    init(@ViewBuilder content: () -> Content) {
        self._expanded = State(initialValue: true).projectedValue
        self.staticState = true
        self.collapsedIcon = nil
        self.content = content()
    }
}

#Preview {
    @State var expanded1: Bool = false
    @State var expanded2: Bool = true

    return VStack {
        Popup(expanded: $expanded1, collapsedIcon: "scope") {
            Text("Title")
        }

        Popup(expanded: $expanded2, collapsedIcon: "scope") {
            Text("Title")
        }

        Popup {
            Text("Title")
        }
    }
}
