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

protocol SlackCell {
    var user: User? { get set }
    func displayCell()
}

protocol SlackViewController: class {
    var slackChannelManager: SlackChannelManager? { get set }
    var filteredUsers: [User]? { get set }
    var searchBar: SlackSearchBar! { get set }

    func filterContentForSearchText(searchText: String)
    func filterContentForScope(index: Int)
    func filterContent(index: Int, searchText: String)
}

extension SlackViewController {
    func filterContentForSearchText(searchText: String) {
        guard let filteredUsers = self.slackChannelManager?.filtered(content: self.filteredUsers, for: searchText) else { return }
        self.filteredUsers = filteredUsers
    }

    func filterContentForScope(index: Int) {
        guard
            let scopeButtons = self.searchBar.scopeButtonTitles,
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
