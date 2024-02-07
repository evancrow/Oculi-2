//
//  Slider.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

private struct SliderDefaults {
    static let SliderHeight: CGFloat = 30
    static let ButtonSize: CGFloat = 60
}

struct Slider: View {
    @Binding var value: CGFloat

    var body: some View {
        GeometryReader { geom in
            ZStack {
                Rectangle()
                    .frame(height: SliderDefaults.SliderHeight)
                    .foregroundStyle(Color(uiColor: .secondarySystemFill))

                HStack {
                    let width = geom.size.width - (PaddingSizes._52 * 2) - SliderDefaults.ButtonSize
                    Rectangle()
                        .frame(width: SliderDefaults.ButtonSize, height: SliderDefaults.ButtonSize)
                        .foregroundStyle(Color.Oculi.Pink)
                        .onScroll(name: "slider", direction: .horizontal) { offset in
                            value = offset / width
                        }

                    Spacer()
                        .frame(width: width * (1 - value))
                }.padding(.horizontal, PaddingSizes._52)
            }
        }.frame(height: SliderDefaults.ButtonSize)
    }
}

#Preview {
    GeometryReader { geom in
        Slider(value: .constant(0))
            .environmentObject(GeometryProxyValue(geom: geom))
            .environmentObject(InteractionManager())
    }
}
