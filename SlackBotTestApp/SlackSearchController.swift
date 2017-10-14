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

protocol SlackViewController {
    var slackChannelManager: SlackChannelManager? { get set }
    var filteredUsers: [User]? { get set }
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
