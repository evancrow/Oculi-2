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
    case Developer
    case EvanCrow

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
        case .Developer:
            DeveloperPage()
        case .EvanCrow:
            EvanCrowPage()
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
        case .Developer:
            return .Playground
        case .EvanCrow:
            return .Playground
        }
    }
}

class NavigationModel: ObservableObject {
    @Published private(set) var navigationStack: [Page]

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
        self.navigationStack.append(page)
    }

    init() {
        self.navigationStack = [.Landing]
    }
}
