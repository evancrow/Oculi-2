//
//  Popup.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct Popup<Content: View>: View {
    @State private var expanded: Bool
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
                    }.buttonStyle(UnderlinedButtonStyle())
                }
            } else {
                Button(action: toggleExpandedState) {
                    Image(systemName: collapsedIcon ?? "")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
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
        expanded: Bool = false,
        collapsedIcon: String,
        @ViewBuilder content: () -> Content
    ) {
        self._expanded = State(initialValue: expanded)
        self.staticState = false
        self.collapsedIcon = collapsedIcon
        self.content = content()
    }

    init(@ViewBuilder content: () -> Content) {
        self._expanded = State(initialValue: true)
        self.staticState = true
        self.collapsedIcon = nil
        self.content = content()
    }
}

#Preview {
    VStack {
        Popup(collapsedIcon: "scope") {
            Text("Title")
        }

        Popup(expanded: true, collapsedIcon: "scope") {
            Text("Title")
        }

        Popup {
            Text("Title")
        }
    }
}
