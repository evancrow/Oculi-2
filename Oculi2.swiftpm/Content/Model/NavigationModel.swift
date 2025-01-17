//
//  File.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import Foundation
import SwiftUI

enum Page {
    case Landing
    case About
    case Calibrate
    case Tutorial
    case Playground

    @ViewBuilder
    var page: some View {
        switch self {
        case .Landing:
            LandingPage()
        case .About:
            AboutPage()
        case .Calibrate:
            CalibrationPage()
        case .Tutorial:
            TutorialPage()
        case .Playground:
            PlaygroundPage()
        }
    }

    var nextPage: Page? {
        switch self {
        case .Landing:
            return .About
        case .About:
            return .Calibrate
        case .Calibrate:
            return .Tutorial
        case .Tutorial:
            return .Playground
        case .Playground:
            return nil
        }
    }
}

class NavigationModel: ObservableObject {
    @Published private(set) var navigationStack: [Page] {
        didSet {
            pageId = UUID()
        }
    }
    @Published private(set) var pageId: UUID = UUID()

    func moveToNextPage(popFirst: Bool = false) {
        if popFirst, navigationStack.count > 1 {
            navigationStack.removeLast()
        } else {
            guard let nextPage = navigationStack.last?.nextPage else {
                return
            }

            self.navigationStack = [nextPage]
        }
    }

    func goTo(page: Page) {
        self.navigationStack = [page]
    }

    func stack(page: Page) {
        if navigationStack.last == page {
            navigationStack.removeLast()
        }

        self.navigationStack.append(page)
    }

    init() {
        self.navigationStack = [.Landing]
    }
}
