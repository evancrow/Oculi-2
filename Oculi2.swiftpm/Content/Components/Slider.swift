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
    @State private var width: CGFloat = 0

    var sliderBoundsWidth: CGFloat {
        width - (PaddingSizes._52 * 2) - SliderDefaults.ButtonSize
    }

    var body: some View {
        ZStack {
            GeometryReader { geom in
                Rectangle()
                    .frame(height: SliderDefaults.SliderHeight)
                    .foregroundStyle(Color(uiColor: .secondarySystemFill))
                    .useEffect(deps: geom.size) { value in
                        self.width = value.width
                    }
            }

            HStack {
                Rectangle()
                    .frame(width: SliderDefaults.ButtonSize, height: SliderDefaults.ButtonSize)
                    .foregroundStyle(Color.Oculi.Pink)
                    .onDrag(
                        name: "slider",
                        lockAxis: .horizontal,
                        maximum: CGSize(width: sliderBoundsWidth, height: 0)
                    ) { offset in
                        value = offset.width / sliderBoundsWidth
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
