//
//  MeetingViewController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKWebAPI

class MeetingViewController: UIViewController, SlackViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var companyLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!

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
    var currentFocusIndex = 0 {
        didSet {
            if self.currentFocusIndex > 4 {
                self.currentFocusIndex = 1
            }
            else if self.currentFocusIndex < 1 {
                self.currentFocusIndex = 4
            }

            if self.currentFocusIndex == 4 {
                self.searchController.searchBar.becomeFirstResponder()
                return
            }

            for view in self.view.subviews {
                if view.tag == self.currentFocusIndex {
                    view.becomeFirstResponder()
                    return
                }
            }
        }
    }

    lazy var previousNextToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()

        let previousBarButtonItem = UIBarButtonItem(title: "Previous",
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(MeetingViewController.previousButtonTapped(_:)))
        let nextBarButtonItem = UIBarButtonItem(title: "Next",
                                                style: .plain,
                                                target: self,
                                                action: #selector(MeetingViewController.nextButtonTapped(_:)))

        toolbar.setItems([previousBarButtonItem, nextBarButtonItem], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController.setupSearchController(in: self,
                                                    with: self.tableView,
                                                    with: self.slackStore?.sortedChannels.map { $0.defaultName })

        self.setupNavigationItem()
        self.definesPresentationContext = true
        self.filterContentForScope(index: 0)
        self.setupDelegates()
        self.setupTags()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.nameLabel.becomeFirstResponder()
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

        DispatchQueue.global(qos: .background).async {
            for indexPath in indexPaths {
                sleep(2)
                self.slackStore?.sendMessage(channel: scopeButtons[searchBar.selectedScopeButtonIndex],
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

    private func setupNavigationItem() {
        self.navigationItem.title = "Meeting"
        self.notifyButton = UIBarButtonItem(barButtonSystemItem: .action,
                                            target: self,
                                            action: #selector(MeetingViewController.notifyButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.notifyButton
        self.automaticallyAdjustsScrollViewInsets = false
    }

    private func setupDelegates() {
        self.searchController.searchBar.delegate = self
        self.nameLabel.delegate = self
        self.companyLabel.delegate = self
        self.emailLabel.delegate = self
    }

    private func setupTags() {
        self.nameLabel.tag = 1
        self.companyLabel.tag = 2
        self.emailLabel.tag = 3
        self.searchController.searchBar.tag = 4
        self.currentFocusIndex = 1
    }

    func previousButtonTapped(_ sender: UIBarButtonItem) {
        self.currentFocusIndex -= 1
    }

    func nextButtonTapped(_ sender: UIBarButtonItem) {
        self.currentFocusIndex += 1
    }
}

extension MeetingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.searchController.searchBarIsActive()) ? (self.filteredUsers?.count ?? 0) : (self.slackStore?.usersArray.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingTableViewCell
        cell.user = (self.searchController.searchBarIsActive()) ? self.filteredUsers?[indexPath.row] : self.slackStore?.usersArray[indexPath.row]
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

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.inputAccessoryView = self.previousNextToolbar
        return true
    }

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

extension MeetingViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = self.previousNextToolbar
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.currentFocusIndex += 1

        return true
    }
}
