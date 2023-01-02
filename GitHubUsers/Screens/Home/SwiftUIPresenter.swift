//
//  ProfileViewPresenter.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 06/01/2023.
//

import SwiftUI

protocol SwiftUIPresentable: UIViewController { }

class SwiftUIPresenter<T> where T: View {
    private var viewController: UIViewController?
    private var swiftUIView: T?

    init(viewController: UIViewController? = nil, swiftUIView: T? = nil) {
        self.viewController = viewController
        self.swiftUIView = swiftUIView
    }

    func present() {
        guard let swiftUIView = self.swiftUIView else {
            fatalError("SwiftUIPresenter is misconfigured. Missing view.")
        }

        guard let navigationController = viewController?.navigationController else {
            fatalError("SwiftUIPresenter is misconfigured. Missing navigation controller.")
        }

        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}
