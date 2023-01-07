//
//  ProfileViewPresenter.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 06/01/2023.
//

import SwiftUI

/// Type erases to erase the `UIViewController` type for use in view model so that the view model is not required to import `UIKit`.
protocol SwiftUIPresentable: UIViewController { }

/// Static method(s) for presenting `SwiftUI` view from `UIKit` view controller.
///
/// - Parameters:
///   - viewController: The view controller to present the `SwiftUI` view.
///   - swiftUIView: The `SwiftUI` view to be presented.
struct SwiftUIPresenter {
    /// Method to present a `SwiftUI` view from a given `UIViewController`.
    static func present<T>(viewController: UIViewController, swiftUIView: T) where T: View {
        guard let navigationController = viewController.navigationController else {
            fatalError("viewController is missing navigation controller.")
        }

        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}
