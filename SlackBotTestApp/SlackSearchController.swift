//
//  SlackSearchController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-16.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKCore
import SKWebAPI

protocol SlackTableViewCell {
    var user: User? { get set }
    func displayCell()
}

protocol SlackViewController: class {
    var slackChannelManager: SlackChannelManager? { get set }
    var filteredUsers: [User]? { get set }
    var searchController: SlackSearchController { get set }

    func filterContentForSearchText(searchText: String)
    func filterContentForScope(index: Int)
    func filterContent(index: Int, searchText: String)
}

extension SlackViewController {
    func filterContentForSearchText(searchText: String) {
        guard let filteredUsers = self.searchController.filter(content: self.filteredUsers, for: searchText) else { return }
        self.filteredUsers = filteredUsers
    }

    func filterContentForScope(index: Int) {
        guard
            let scopeButtons = self.searchController.searchBar.scopeButtonTitles,
            scopeButtons.startIndex <= index && index < scopeButtons.endIndex,
            let team = self.slackChannelManager?.slackTeam(for: scopeButtons[index]),
            let users = self.slackChannelManager?.users(for: team)
        else { return }

        self.filteredUsers = users
    }

    func filterContent(index: Int, searchText: String) {
        self.filterContentForScope(index: index)
        self.filterContentForSearchText(searchText: searchText)
    }
}

class SlackSearchController: UISearchController {

    lazy var _searchBar: SlackSearchBar = { [unowned self] in
        let searchBar = SlackSearchBar(frame: CGRect.zero)
        return searchBar
    }()

    override var searchBar: UISearchBar {
        return _searchBar
    }

    func setupSearchController<T: UISearchResultsUpdating>(in viewController: T, with tableView: UITableView, in navigationItem: UINavigationItem, with scopeButtonTitles: [String]?) {
        self.searchResultsUpdater = viewController
        self.setupSearchBarStyle(with: tableView, in: navigationItem)
        self.searchBar.scopeButtonTitles = scopeButtonTitles
    }

    private func setupSearchBarStyle(with tableView: UITableView, in navigationItem: UINavigationItem) {
        self.dimsBackgroundDuringPresentation = false
        self.hidesNavigationBarDuringPresentation = false

        if #available(iOS 11.0, *) {
            navigationItem.searchController = self
        }
        else {
            tableView.tableHeaderView = self.searchBar
        }
    }

    func searchBarIsActive() -> Bool {
        return self.isActive
    }

    func filter(content: [User]?, for searchText: String) -> [User]? {
        guard
            self.searchBarIsActive(),
            let content = content else {
            return nil
        }

        return content.filter { user in
            return searchText.isEmpty || (user.profile?.realName?.lowercased().range(of: searchText.lowercased()) != nil)
        }
    }
}
