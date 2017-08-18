//
//  DeliveryViewController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-01.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKWebAPI

class DeliveryViewController: UIViewController, SlackViewController {

    @IBOutlet weak var tableView: UITableView!
    var notifyButton: UIBarButtonItem!
    let searchController = SlackSearchController(searchResultsController: nil)

    var _slackStore: SlackStore?
    var slackStore: SlackStore? {
        get {
            return self._slackStore
        }
        set {
            self._slackStore = newValue
        }
    }

    var _filteredUsers: [User]?
    var filteredUsers: [User]? {
        get {
            return self._filteredUsers
        }
        set {
            self._filteredUsers = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController.setupSearchController(in: self,
                                                    with: self.tableView,
                                                    with: self.slackStore?.sortedChannels.map { $0.name! })

        self.setupNavigationItem()
        self.definesPresentationContext = true
        self.searchController.searchBar.delegate = self
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

        DispatchQueue.global(qos: .background).async {
            for indexPath in indexPaths {
                sleep(2)
                self.slackStore?.sendMessage(channel: scopeButtons[searchBar.selectedScopeButtonIndex],
                                             text: "",
                                             linkNames: true,
                                             attachments: Attachment.deliveryAttachment(for: self.tableView.cellForRow(at: indexPath) as! DeliveryTableViewCell),
                                             success: nil,
                                             failure: nil)
            }
        }
    }

    private func setupNavigationItem() {
        self.navigationItem.title = "Delivery"
        self.notifyButton = UIBarButtonItem(barButtonSystemItem: .action,
                                            target: self,
                                            action: #selector(MeetingViewController.notifyButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.notifyButton
    }

    func filterContentForSearchText(searchText: String) {
        guard let filteredUsers = self.searchController.filter(content: self.filteredUsers, for: searchText) else { return }
        self.filteredUsers = filteredUsers
    }

    func filterContentForScope(index: Int) {

        guard let filteredUsers = self.searchController.filter(content: self.slackStore?.usersArray,
                                                               in: self.slackStore,
                                                               for: index) else {
                                                                return
        }

        self.filteredUsers = filteredUsers
    }

    func reloadData(criterion: Bool = true) {
        if criterion {
            self.tableView.reloadData()
        }
    }
}

extension DeliveryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.searchController.searchBarIsActive()) ? (self.filteredUsers?.count ?? 0) : (self.slackStore?.usersArray.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! SlackTableViewCell
        cell.user = (self.searchController.searchBarIsActive()) ? self.filteredUsers?[indexPath.row] : self.slackStore?.usersArray[indexPath.row]
        cell.displayCell()
        return cell as! UITableViewCell
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
            let searchText = searchBar.text ?? ""
            let splice = String(searchText.characters.dropLast())
            self.filterContentForSearchText(searchText: splice)
            self.reloadData()
        }
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            self.filterContentForSearchText(searchText: searchBar.text ?? "")
            self.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let text = searchBar.text else { return }
        self.filterContentForScope(index: selectedScope)
        self.filterContentForSearchText(searchText: text)
        self.reloadData()
    }
}

