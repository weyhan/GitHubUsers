//
//  HomeViewController.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 15/12/2022.
//

import UIKit

/// Home view controller
///
/// List GitHub users from GitHub's API for user list
class HomeViewController: UIViewController, UITableViewDataSource {

    @IBOutlet var statusContainerView: UIView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        statusContainerView.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self
    }

}

// MARK: - Notification Extension
extension HomeViewController {

    /// Slide in the status bar from below the navigation bar.
    ///
    /// - Parameters:
    ///   - text: The text to display on the status bar.
    func showStatus(text: String) {
        let transform = statusView.transform.translatedBy(x: 0, y: 44)

        statusContainerView.isHidden = false

        var inset = tableView.contentInset
        inset.top += 44

        statusLabel.text = text

        let animations: ()->() = {
            self.statusView.transform = transform
            self.tableView.contentInset = inset
        }

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [ .curveEaseOut ],
                       animations: animations,
                       completion: nil)
    }

    /// Slide away the status bar.
    func hideStatus() {
        let transform = statusView.transform.translatedBy(x: 0, y: -44)
        var inset = tableView.contentInset
        inset.top -= 44

        let animations: ()->() = {
            self.statusView.transform = transform
            self.tableView.contentInset = inset
        }

        statusLabel.text = ""

        let completion: (Bool)->() = { _ in
            self.statusContainerView.isHidden = true
        }

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [ .curveEaseOut ],
                       animations: animations,
                       completion: completion)
    }

}

// MARK: - UITableViewDelegate Extension
extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        }
    }

}
