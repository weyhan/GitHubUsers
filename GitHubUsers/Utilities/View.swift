//
//  View.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 10/01/2023.
//

import SwiftUI
import Combine

extension View {

    /// Publish keyboard did show and did hide event.
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardDidShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardDidHideNotification)
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

}
