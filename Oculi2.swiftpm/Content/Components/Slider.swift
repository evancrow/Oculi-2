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
    @State private var offset: CGSize = .zero
    @State private var maximum: CGSize = .zero

    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: SliderDefaults.SliderHeight)
                .foregroundStyle(Color.Oculi.Secondary)
                .onViewBoundsChange { bounds in
                    maximum = CGSize(
                        width: bounds.width - (PaddingSizes._52 * 2) - SliderDefaults.ButtonSize,
                        height: 0
                    )
                }

            HStack {
                Rectangle()
                    .frame(width: SliderDefaults.ButtonSize, height: SliderDefaults.ButtonSize)
                    .foregroundStyle(Color.Oculi.Pink)
                    .onDrag(
                        name: "slider",
                        lockAxis: .horizontal,
                        minimum: CGSize(width: 0, height: 0),
                        maximum: maximum
                    ) { offset in
                        value = offset.width / maximum.width
                    }
                
                Spacer()
            }.padding(.horizontal, PaddingSizes._52)
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
