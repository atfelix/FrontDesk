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

    var _slackChannelManager: SlackChannelManager?
    var slackChannelManager: SlackChannelManager? {
        get {
            return self._slackChannelManager
        }
        set {
            self._slackChannelManager = newValue
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController.setupSearchController(in: self,
                                                    with: self.tableView,
                                                    in: self.navigationItem,
                                                    with: self.slackChannelManager?.channels.map { $0.name })
        self.setupNavigationItem()
        self.definesPresentationContext = true
        self.tableView.keyboardDismissMode = .interactive
        self.searchController.searchBar.delegate = self
        self.searchController.delegate = self
        self.filterContentForScope(index: 0)
        self.registerKeyboardNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.searchController.isActive = true
    }

    func notifyButtonTapped(_ sender: UIButton) {

        guard self.tableView.indexPathsForSelectedRows != nil else {
            self.alertLetterCarrier()
            return
        }

        let searchBar = self.searchController.searchBar

        guard
            let indexPaths = self.tableView.indexPathsForSelectedRows,
            let scopeButtons = searchBar.scopeButtonTitles else {
                return
        }

        guard let team = self.slackChannelManager?.slackTeam(for: scopeButtons[searchBar.selectedScopeButtonIndex]) else { return }

        var indexPathData = [(User, Bool, Bool)]()

        for indexPath in indexPaths {
            guard
                let cell = self.tableView.cellForRow(at: indexPath) as? DeliveryTableViewCell,
                let user = cell.user
            else { continue }

            let leftAtFrontDesk = cell.leftAtFrontDeskSwitch.isOn
            let signatureRequired = cell.signatureRequiredSwitch.isOn

            indexPathData.append((user, leftAtFrontDesk, signatureRequired))
        }

        DispatchQueue.global(qos: .background).async {
            for (user, leftAtFrontDesk, signatureRequired) in indexPathData {
                self.slackChannelManager?.sendMessage(to: [user],
                                                      on: team,
                                                      regularAttachments: Attachment.regularDeliveryAttachment(for: user,
                                                                                                               leftAtFrontDesk: leftAtFrontDesk,
                                                                                                               signatureRequired: signatureRequired),
                                                      awayAttachments:Attachment.awayDeliveryAttachement(for: user,

                                                                                                         leftAtFrontDesk: leftAtFrontDesk,
                                                                                                         signatureRequired: signatureRequired,                                                      channel: team.channelName),
                                                      dndAttachments:Attachment.dndDeliveryAttachement(for: user, leftAtFrontDesk: leftAtFrontDesk,
                                                                                                       signatureRequired: signatureRequired,
                                                                                                       channel: team.channelName))
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

        let searchBar = self.searchController.searchBar

        guard
            let scopeButtons = searchBar.scopeButtonTitles,
            scopeButtons.startIndex <= index && index < scopeButtons.endIndex else {
                return

        }

        guard
            let team = self.slackChannelManager?.slackTeam(for: scopeButtons[index]),
            let users = self.slackChannelManager?.users(for: team) else {
                                                                return
        }

        self.filteredUsers = users
    }

    func reloadData(criterion: Bool = true) {
        if criterion {
            self.tableView.reloadData()
        }
    }

    func filterContent(index: Int, searchText: String) {
        self.filterContentForScope(index: index)
        self.filterContentForSearchText(searchText: searchText)
    }

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MeetingViewController.keyboardWillShow),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MeetingViewController.keyboardWillHide),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardSize = keyboardRect.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)

        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }

    func keyboardWillHide(_ notification: Notification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    private func alertLetterCarrier() {
        let alert = UIAlertController(title: "Invalid Selection",
                                      message: "Please choose at least one person",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension DeliveryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredUsers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! SlackTableViewCell
        cell.user = self.filteredUsers?[indexPath.row]
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
            let searchText = searchBar.text ?? ""
            self.filterContent(index: searchBar.selectedScopeButtonIndex,
                               searchText: String(searchText.characters.dropLast()))
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
        self.filterContent(index: selectedScope, searchText: text)
        self.reloadData()
    }
}

extension DeliveryViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}
