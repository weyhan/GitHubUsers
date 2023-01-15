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
class HomeViewController: UIViewController, HomeViewDelegate, SwiftUIPresentable {

    @IBOutlet var statusContainerView: UIView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var tableView: UITableView!

    private let viewModel = HomeViewModel()

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        statusContainerView.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self

        viewModel.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        let searchBar = searchController.searchBar
        let searchTextField = searchBar.searchTextField

        let headerSecondaryForegroundColor = UIColor(named: "headerSecondaryForegroundColor") ?? .lightGray

        let placeholderAttribute = [ NSAttributedString.Key.foregroundColor : headerSecondaryForegroundColor ]
        let attributedPlaceholder = NSAttributedString(string: "Search Users", attributes: placeholderAttribute)
        searchTextField.attributedPlaceholder = attributedPlaceholder

        searchTextField.backgroundColor = UIColor(named: "headerContraColor")
        searchTextField.textColor = UIColor(named: "headerForegroundColor")
        searchTextField.leftView?.tintColor = UIColor(named: "headerForegroundColor")

        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: - Data

extension HomeViewController {

    /// Reloads the rows and sections of the table view.
    func refreshUI() {
        tableView.reloadData()
    }

    /// Reloads the table view cell at a certain row.
    ///
    /// - Parameters:
    ///   - rowAt: Row number of the cell to update.
    func refresh(rowAt row: Int) {
        if !viewModel.isSearchMode {
            tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
}

// MARK: - Notification Extension
extension HomeViewController {

    /// Slide in the status bar from below the navigation bar.
    ///
    /// - Parameters:
    ///   - text: The text to display on the status bar.
    func showStatus(text: String) {
        statusLabel.text = text

        // Don't move statusView if the statusView is already on screen.
        guard statusContainerView.isHidden == true else { return }

        statusContainerView.isHidden = false

        // Use the distance between the current location and the destination for
        // the move transform instead of a hardcoded number. This will prevent
        // runaway move from unintentional multiple calls to this method.
        let moveYBy = statusView.frame.minY.distance(to: 0)
        let transform = statusView.transform.translatedBy(x: 0, y: moveYBy)

        var inset = tableView.contentInset
        inset.top = 44

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
        guard statusContainerView.isHidden == false else { return }

        // Use the distance between the current location and the destination for
        // the move transform instead of a hardcoded number. This will prevent
        // runaway move from unintentional multiple calls to this method.
        let moveYBy = statusView.frame.minY.distance(to: -44)
        let transform = statusView.transform.translatedBy(x: 0, y: moveYBy)

        // Reset tableView inset to 0 if the top value is less than 44.0. Similar
        // to the above, is to prevent multiple calls to this method.
        var inset = tableView.contentInset
        inset.top = inset.top > 44 ? inset.top - 44 : 0

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
        guard let homeTableViewCell = cell as? HomeTableViewCellProtocol else {
            fatalError("Home UITableView is misconfigured.")
        }

        homeTableViewCell.setup(withViewModel: cellViewModel)

        return cell
    }

}

// MARK: - UITableViewDelegate Extension

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        viewModel.didSelectRowAt(row: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let footerViewModel = viewModel.cellViewModelForFooter()
        let reuseIdentifier = footerViewModel.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)

        // Setup cell with view model.
        guard let footerCell = cell as? HomeFooterTableViewCellProtocol else {
            fatalError("Home UITableView is misconfigured.")
        }

        footerCell.setup(withViewModel: footerViewModel)

        viewModel.loadNewData()

        return cell
    }

}

// MARK: - Search User Extension
extension HomeViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterUser(forSearchText: searchController.searchBar.text)
    }

}
