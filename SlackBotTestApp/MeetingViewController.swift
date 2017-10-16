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
    var currentFocusIndex = 1 {
        didSet {
            self.currentFocusIndex = ((self.currentFocusIndex + 4) % 4)
            if self.currentFocusIndex == 0 {
                self.currentFocusIndex = 4
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

    deinit {
        self.deregisterNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController.setupSearchController(in: self,
                                                    with: self.tableView,
                                                    in: self.navigationItem,
                                                    with: self.slackChannelManager?.teams.map { $0.name })

        self.setupNavigationItem()
        self.definesPresentationContext = true
        self.tableView.keyboardDismissMode = .interactive
        self.filterContentForScope(index: 0)
        self.setupDelegates()
        self.setupTags()
        self.determineFirstResponder()
        self.registerKeyboardNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.searchController.isActive = true
    }

    func notifyButtonTapped(_ sender: UIButton) {

        let searchBar = self.searchController.searchBar

        guard
            let indexPaths = self.tableView.indexPathsForSelectedRows,
            let scopeButtons = searchBar.scopeButtonTitles,
            let name = self.nameLabel.text,
            let company = self.companyLabel.text,
            let email = self.emailLabel.text,
            !name.isEmpty && !email.isEmpty && String.isValid(email: email),
            let team = self.slackChannelManager?.slackTeam(for: scopeButtons[searchBar.selectedScopeButtonIndex]) else {
                return
        }

        DispatchQueue.global(qos: .background).async {
            for indexPath in indexPaths {
                guard
                    let cell = self.tableView.cellForRow(at: indexPath) as? MeetingTableViewCell,
                    let user = cell.user else {
                        continue
                }

                self.slackChannelManager?.sendMessage(to: [user],
                                                      on: team,
                                                      regularAttachments: Attachment.meetingAttachment(for: cell,
                                                                                                       name: name,
                                                                                                       from: company,
                                                                                                       with: email),
                                                      awayAttachments: Attachment.awayMeetingAttachment(for: cell,
                                                                                                        team: team,
                                                                                                        name: name,
                                                                                                        from: company,
                                                                                                        with: email),
                                                      dndAttachments: Attachment.dndMeetingAttachment(for: cell,
                                                                                                      team: team,
                                                                                                      name: name,
                                                                                                      from: company,
                                                                                                      with: email))
            }
        }
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

    func updateNotifyButton() {
        guard
            let name = self.nameLabel.text,
            let email = self.emailLabel.text else {
                self.notifyButton.isEnabled = false
                return
        }

        self.notifyButton.isEnabled = (self.tableView.indexPathsForSelectedRows != nil
            && !name.isEmpty && !email.isEmpty && String.isValid(email: email))
    }

    private func setupNavigationItem() {
        self.navigationItem.title = "Meeting"
        self.notifyButton = UIBarButtonItem(barButtonSystemItem: .action,
                                            target: self,
                                            action: #selector(MeetingViewController.notifyButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.notifyButton
        self.notifyButton.isEnabled = false
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
    }

    func determineFirstResponder() {
        if self.currentFocusIndex == 4 {
            self.searchController.searchBar.becomeFirstResponder()
            return
        }

        for subview in self.view.subviews where subview.tag == self.currentFocusIndex {
            subview.becomeFirstResponder()
        }
    }

    func previousButtonTapped(_ sender: UIBarButtonItem) {
        self.currentFocusIndex -= 1
        self.determineFirstResponder()
    }

    func nextButtonTapped(_ sender: UIBarButtonItem) {
        self.currentFocusIndex += 1
        self.determineFirstResponder()
    }

    func filterContent(index: Int, searchText: String) {
        self.filterContentForScope(index: index)
        self.filterContentForSearchText(searchText: searchText)
    }

    private func deregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerKeyboardNotifications() {
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
}


extension MeetingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredUsers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingTableViewCell
        cell.user = self.filteredUsers?[indexPath.row]
        cell.displayCell()
        return cell
    }
}

extension MeetingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateNotifyButton()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.updateNotifyButton()
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
        self.currentFocusIndex = searchBar.tag
        searchBar.inputAccessoryView = self.previousNextToolbar
        return true
    }

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
        self.updateNotifyButton()
        if searchBar.text != "" {
            self.filterContentForSearchText(searchText: searchBar.text ?? "")
            self.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let text = searchBar.text else { return }
        self.filterContent(index: selectedScope, searchText: text)
        self.reloadData()
        self.updateNotifyButton()
    }
}

extension MeetingViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.currentFocusIndex = textField.tag
        textField.inputAccessoryView = self.previousNextToolbar
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.currentFocusIndex += 1
        self.determineFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateNotifyButton()
        return true
    }
}
