//
//  DeliveryViewController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-01.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKWebAPI

class DeliveryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var notifyButton: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)

    var channelStore: ChannelStore!
    var webAPI: WebAPI!
    var filteredUsers: [User]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationItem()
        self.setupSearchController()
        self.filterContentForScope(index: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.searchController.searchBar.becomeFirstResponder()
        self.searchController.isActive = true
    }

    func notifyButtonTapped(_ sender: UIButton) {

        let searchBar = self.searchController.searchBar

        guard
            let indexPaths = self.tableView.indexPathsForSelectedRows,
            let scopeButtons = searchBar.scopeButtonTitles else {
                return
        }

        for indexPath in indexPaths {
            sleep(2)
            self.webAPI.sendMessage(channel: scopeButtons[searchBar.selectedScopeButtonIndex],
                                    text: "",
                                    linkNames: true,
                                    attachments: Attachment.deliveryAttachment(for: self.tableView.cellForRow(at: indexPath) as! DeliveryTableViewCell),
                                    success: nil,
                                    failure: nil)
        }
    }

    private func setupNavigationItem() {
        self.navigationItem.title = "Delivery"
        self.notifyButton = UIBarButtonItem(barButtonSystemItem: .action,
                                            target: self,
                                            action: #selector(MeetingViewController.notifyButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.notifyButton
    }

    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.setupSearchBarStyle()
        self.searchController.searchBar.scopeButtonTitles = self.channelStore.sortedChannels.map { $0.name! }
    }

    func searchBarIsActive() -> Bool {
        return self.searchController.isActive && self.searchController.searchBar.text != ""
    }

    private func setupSearchBarStyle() {
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
    }

    func filterContentForSearchText(searchText: String) {
        guard self.searchBarIsActive() else { return }

        self.filteredUsers = self.filteredUsers.filter { user in
            return (user.profile?.realName?.lowercased().contains(searchText.lowercased())) ?? (searchText == "")
        }
        self.tableView.reloadData()
    }

    func filterContentForScope(index: Int) {
        guard let members = self.channelStore.sortedChannels[index].members else { return }

        self.filteredUsers = self.channelStore.usersArray.filter { user in
            guard let id = user.id else { return false }
            return members.contains(id)
        }
        self.tableView.reloadData()
    }
}

extension DeliveryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.searchBarIsActive()) ? self.filteredUsers.count : self.channelStore.usersArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! DeliveryTableViewCell
        cell.user = (self.searchBarIsActive()) ? self.filteredUsers[indexPath.row] : self.channelStore.usersArray[indexPath.row]
        cell.displayCell()
        return cell
    }
}

extension DeliveryViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        self.filterContentForSearchText(searchText: text)
    }
}

extension DeliveryViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            self.filterContentForScope(index: searchBar.selectedScopeButtonIndex)
        }
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            self.filterContentForSearchText(searchText: searchBar.text ?? "")
        }
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let text = searchBar.text else { return }
        self.filterContentForScope(index: selectedScope)
        self.filterContentForSearchText(searchText: text)
    }
}
