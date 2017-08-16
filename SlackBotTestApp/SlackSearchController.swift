//
//  SlackSearchController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-16.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKCore

class SlackSearchController: UISearchController {

    func setupSearchController<T: UISearchResultsUpdating>(in viewController: T, with tableView: UITableView, with scopeButtonTitles: [String]) {
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

    func filter(content: [User], for searchText: String) -> [User]? {
        guard self.searchBarIsActive() else {
            return nil
        }

        return content.filter { user in
            return searchText.isEmpty || (user.profile?.realName?.lowercased().contains(searchText.lowercased()) ?? false)
        }
    }

    func filter(content: [User], in channelStore: ChannelStore, for scopeIndex: Int) -> [User]? {
        guard let members = channelStore.sortedChannels[scopeIndex].members else { return nil }

        return content.filter { user in
            guard let id = user.id else { return false }
            return members.contains(id)
        }
    }
}
