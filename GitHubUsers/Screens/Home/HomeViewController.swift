//
//  HomeViewController.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 15/12/2022.
//

import UIKit
import CoreData

/// Home view controller
///
/// List GitHub users from GitHub's API for user list
class HomeViewController: UIViewController, HomeViewDelegate {

    @IBOutlet var statusContainerView: UIView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var tableView: UITableView!

    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        statusContainerView.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self

        viewModel.delegate = self

        // TODO: Move trigger to footer cell when ready
        viewModel.loadNewData()
    }

}

// MARK: - Data

extension HomeViewController {

    /// Reloads the rows and sections of the table view.
    func refreshUI() {
        tableView.reloadData()
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

// MARK: - UITableViewDataSource Extension
extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(forRowAt: indexPath.row)
        let reuseIdentifier = cellViewModel.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Setup cell with view model.
        guard let homeTableViewCell = cell as? HomeTableViewCell else {
            fatalError("Home UITableView misconfigured.")
        }

        homeTableViewCell.setup(withViewModel: cellViewModel)

        return cell
    }

}

// MARK: - UITableViewDataSource Extension

extension HomeViewController: UITableViewDelegate {

}
