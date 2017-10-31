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

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var companyLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var searchBar: SlackSearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    var notifyButton: UIBarButtonItem!

    var slackChannelManager: SlackChannelManager? = nil
    var filteredUsers: [User]? = nil
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

        self.collectionView.register(UINib(nibName: "SlackCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SlackCell")
        self.setupNavigationItem()
        self.searchBar.scopeButtonTitles = self.slackChannelManager?.channels.map { $0.name }
        self.searchBar.showsScopeBar = true
        self.definesPresentationContext = true
        self.collectionView.keyboardDismissMode = .interactive
        self.collectionView.allowsMultipleSelection = true
        self.filterContentForScope(index: 0)
        self.setupDelegates()
        self.setupTags()
        self.determineFirstResponder()
        self.registerKeyboardNotifications()
    }

    func notifyButtonTapped(_ sender: UIButton) {
        guard self.formIsValid()
        else {
            self.alertMeetingGoer()
            return
        }

        guard
            let searchBar = self.searchBar,
            let indexPaths = self.collectionView.indexPathsForSelectedItems,
            let scopeButtons = searchBar.scopeButtonTitles,
            let name = self.nameLabel.text,
            let company = self.companyLabel.text,
            let email = self.emailLabel.text,
            !name.isEmpty && !email.isEmpty && String.isValid(email: email),
            let team = self.slackChannelManager?.slackTeam(for: scopeButtons[searchBar.selectedScopeButtonIndex])
        else { return }

        var indexPathData = [User]()

        for indexPath in indexPaths {
            guard
                let cell = self.collectionView.cellForItem(at: indexPath) as? SlackCollectionViewCell,
                let user = cell.user
            else { continue }

            indexPathData.append(user)
        }

        DispatchQueue.global(qos: .background).async {
            for user in indexPathData {
                self.slackChannelManager?.sendMessage(to: [user],
                                                      on: team,
                                                      regularAttachments: Attachment.meetingAttachment(for: user,
                                                                                                       name: name,
                                                                                                       from: company,
                                                                                                       with: email),
                                                      awayAttachments: Attachment.awayMeetingAttachment(for: user,
                                                                                                        team: team,
                                                                                                        name: name,
                                                                                                        from: company,
                                                                                                        with: email),
                                                      dndAttachments: Attachment.dndMeetingAttachment(for: user,
                                                                                                      team: team,
                                                                                                      name: name,
                                                                                                      from: company,
                                                                                                      with: email))
            }
        }
    }

    func reloadData(criterion: Bool = true) {
        if criterion {
            self.collectionView.reloadData()
        }
    }

    func formIsValid() -> Bool {
        guard
            let name = self.nameLabel.text,
            let email = self.emailLabel.text else {
                self.notifyButton.isEnabled = false
                return false
        }

        return (self.collectionView.indexPathsForSelectedItems != nil
            && !name.isEmpty && !email.isEmpty && String.isValid(email: email))
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
        self.searchBar.delegate = self
        self.nameLabel.delegate = self
        self.companyLabel.delegate = self
        self.emailLabel.delegate = self
    }

    private func setupTags() {
        self.nameLabel.tag = 1
        self.companyLabel.tag = 2
        self.emailLabel.tag = 3
        self.searchBar.tag = 4
    }

    func determineFirstResponder() {
        if self.currentFocusIndex == 4 {
            self.searchBar.becomeFirstResponder()
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

        self.collectionView.contentInset = contentInsets
        self.collectionView.scrollIndicatorInsets = contentInsets
    }

    func keyboardWillHide(_ notification: Notification) {
        self.collectionView.contentInset = UIEdgeInsets.zero
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    private func alertMeetingGoer() {
        let alert = UIAlertController(title: "Invalid Selection",
                                      message: "Please fill in the \"Name\" field, give a valid email, and select with whom (may be more than one) you're meeting.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension MeetingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredUsers?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlackCell", for: indexPath) as! SlackCollectionViewCell
        cell.user = self.filteredUsers?[indexPath.item]
        cell.displayCell()
        return cell
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
}
