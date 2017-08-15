//
//  MeetingViewController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKWebAPI

class MeetingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var companyLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!

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
            let scopeButtons = searchBar.scopeButtonTitles,
            let name = self.nameLabel.text,
            let company = self.companyLabel.text,
            let email = self.emailLabel.text else {
                return
        }

        for indexPath in indexPaths {
            sleep(2)
            self.webAPI.sendMessage(channel: scopeButtons[searchBar.selectedScopeButtonIndex],
                                    text: "",
                                    linkNames: true,
                                    attachments: Attachment.meetingAttachment(for: self.tableView.cellForRow(at: indexPath) as! MeetingTableViewCell,
                                                                              name: name,
                                                                              from: company,
                                                                              with: email),
                                    success: nil,
                                    failure: { error in
                                        print(error)
            })
        }
    }

    private func setupNavigationItem() {
        self.navigationItem.title = "Meeting"
        self.notifyButton = UIBarButtonItem(barButtonSystemItem: .action,
                                            target: self,
                                            action: #selector(MeetingViewController.notifyButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.notifyButton
        self.automaticallyAdjustsScrollViewInsets = false
    }

    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.setupSearchBarStyle()
        self.searchController.searchBar.scopeButtonTitles = self.channelStore.channels.map { $0.name! }
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
        guard let members = self.channelStore.channels[index].members else { return }

        self.filteredUsers = self.channelStore.usersArray.filter { user in
            guard let id = user.id else { return false }
            return members.contains(id)
        }
        self.tableView.reloadData()
    }
}

extension MeetingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.searchBarIsActive()) ? self.filteredUsers.count : self.channelStore.usersArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingTableViewCell
        cell.user = (self.searchBarIsActive()) ? self.filteredUsers[indexPath.row] : self.channelStore.usersArray[indexPath.row]
        cell.displayCell()
        return cell
    }
}

extension MeetingViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        self.filterContentForSearchText(searchText: text)
    }
}

extension MeetingViewController: UISearchBarDelegate {

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
