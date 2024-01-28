//
//  FontStyles.swift
//  Krater
//
//  Created by Evan Crow on 12/19/23.
//

import Foundation
import SwiftUI

enum FontStyles: String, CaseIterable {
    case Title
    case Title2
    case Title3

    case Header
    case Header2
    case Header3

    case Body
    case Body2
    case Body3

    // MARK: - Font
    private var name: String {
        switch self {
        case .Title, .Title2, .Title3:
            ConcetaFont.Regular.rawValue
        case .Header, .Header2, .Header3:
            AileronFont.SemiBold.rawValue
        case .Body, .Body2, .Body3:
            AileronFont.Regular.rawValue
        }
    }

    private var size: CGFloat {
        switch self {
        case .Title:
            34
        case .Title2:
            28
        case .Title3:
            22
        case .Header:
            24
        case .Header2:
            18
        case .Header3:
            14
        case .Body:
            14
        case .Body2:
            12
        case .Body3:
            10
        }
    }

    private var relativeTo: Font.TextStyle {
        switch self {
        case .Title:
            return .largeTitle
        case .Title2:
            return .title
        case .Title3:
            return .headline
        case .Header:
            return .title2
        case .Header2:
            return .title3
        case .Header3:
            return .body
        case .Body:
            return .body
        case .Body2:
            return .caption
        case .Body3:
            return .caption2
        }
    }

    var font: Font {
        UIFont.loadAllFonts()
        return Font.custom(
            self.name,
            size: self.size,
            relativeTo: self.relativeTo
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(FontStyles.allCases, id: \.self) { style in
            Text(style.rawValue)
                .font(style.font)
        }
    }
}

extension UIFont {
    static var FontsLoaded = false
    
    static func loadAllFonts() {
        guard !FontsLoaded else {
            return
        }
        
        let fontNames = [
            "Aileron-Black",
            "Aileron-BlackItalic",
            "Aileron-Bold",
            "Aileron-BoldItalic",
            "Aileron-Heavy",
            "Aileron-HeavyItalic",
            "Aileron-Italic",
            "Aileron-Light",
            "Aileron-LightItalic",
            "Aileron-Regular",
            "Aileron-SemiBold",
            "Aileron-SemiBoldItalic",
            "Aileron-Thin",
            "Aileron-ThinItalic",
            "Aileron-UltraLight",
            "Aileron-UltraLightItalic",
            "Conceta",
        ]
        fontNames.forEach { loadFont(named: $0) }
        FontsLoaded = true
    }

    private static func loadFont(named name: String) {
        let otf = Bundle.main.url(forResource: name, withExtension: "otf")
        let ttf = Bundle.main.url(forResource: name, withExtension: "ttf")
        
        guard let fontURL = otf ?? ttf,
            let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
            let font = CGFont(fontDataProvider) else
        {
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("Error loading font: \(name)")
        }
    }
}
