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
    var slackStore: SlackStore? { get set }
    var webAPI: WebAPI? { get set }
    var filteredUsers: [User]? { get set }
}

class SlackSearchController: UISearchController {

    func setupSearchController<T: UISearchResultsUpdating>(in viewController: T, with tableView: UITableView, with scopeButtonTitles: [String]?) {
        self.searchResultsUpdater = viewController
        self.setupSearchBarStyle(with: tableView)
        self.searchBar.scopeButtonTitles = scopeButtonTitles
    }

    private func setupSearchBarStyle(with tableView: UITableView) {
        self.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = self.searchBar
        self.hidesNavigationBarDuringPresentation = false
    }

    func searchBarIsActive() -> Bool {
        return self.isActive && self.searchBar.isFirstResponder
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

    func filter(content: [User]?, in slackStore: SlackStore?, for scopeIndex: Int) -> [User]? {
        guard
            let members = slackStore?.sortedChannels[scopeIndex].members,
            let content = content else {
                return nil
        }

        return content.filter { user in
            guard let id = user.id else { return false }
            return members.contains(id)
        }
    }
}
