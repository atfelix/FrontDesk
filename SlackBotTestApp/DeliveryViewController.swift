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
    @IBOutlet weak var searchBar: SlackSearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    var notifyButton: UIBarButtonItem!

    var slackChannelManager: SlackChannelManager? = nil
    var filteredUsers: [User]? = nil

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        self.searchBar.delegate = self
        self.filterContentForScope(index: 0)
        self.registerKeyboardNotifications()
    }

    func notifyButtonTapped(_ sender: UIButton) {

        guard
            let indexPaths = self.collectionView.indexPathsForSelectedItems,
            !indexPaths.isEmpty
        else {
            self.alertLetterCarrier()
            return
        }

        guard
            let searchBar = self.searchBar,
            let scopeButtons = searchBar.scopeButtonTitles,
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
                                                      regularAttachments: Attachment.regularDeliveryAttachment(for: user),
                                                      awayAttachments:Attachment.awayDeliveryAttachement(for: user,
                                                                                                         channel: team.channelName),
                                                      dndAttachments:Attachment.dndDeliveryAttachement(for: user,
                                                                                                       channel: team.channelName))
            }
        }
    }

    private func setupNavigationItem() {
        self.navigationItem.title = "Delivery"
        self.notifyButton = UIBarButtonItem(barButtonSystemItem: .action,
                                            target: self,
                                            action: #selector(DeliveryViewController.notifyButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.notifyButton
    }

    func reloadData(criterion: Bool = true) {
        if criterion {
            self.collectionView.reloadData()
        }
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

        self.collectionView.contentInset = contentInsets
        self.collectionView.scrollIndicatorInsets = contentInsets
    }

    func keyboardWillHide(_ notification: Notification) {
        self.collectionView.contentInset = UIEdgeInsets.zero
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    private func alertLetterCarrier() {
        let alert = UIAlertController(title: "Invalid Selection",
                                      message: "Please choose at least one person",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension DeliveryViewController: UICollectionViewDataSource {
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
