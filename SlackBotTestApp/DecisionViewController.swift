//
//  DecisionViewController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-07-31.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKWebAPI

class DecisionViewController: UIViewController {

    @IBOutlet weak var deliveryButton: UIButton!
    @IBOutlet weak var meetingButton: UIButton!

    var slackChannelManager: SlackChannelManager!

    deinit {
        self.deregisterNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
        self.registerNotifications()
        self.loadActivityController()
        self.slackChannelManager.update()
    }

    private func deregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DecisionViewController.downloadCompleted),
                                               name: NSNotification.Name("SlackChannelManagerDownloadDidFinish"),
                                               object: nil)
    }

    private func loadActivityController() {
        let activityIndicatorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ActivityIndicatorViewController") as! ActivityIndicatorViewController
        self.navigationController?.present(activityIndicatorVC, animated: false)
    }

    private func setupButtons() {
        self.setupDeliveryButton()
        self.setupMeetingButton()
    }

    private func setupDeliveryButton(){
        self.setupDecisionButton(button: self.deliveryButton,
                                 title: "I have a parcel for ...")
    }

    private func setupMeetingButton() {
        self.setupDecisionButton(button: self.meetingButton,
                                 title: "I have a meeting with ...")
    }

    private func setupDecisionButton(button: UIButton, title: String) {
        UIButton.setupDecisionButton(button: button, title: title)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SlackViewController
        vc.slackChannelManager = self.slackChannelManager
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Welcome to LL && DH",
                                                                style: .done,
                                                                target: nil,
                                                                action: nil)
    }

    func downloadCompleted() {
        guard let vc = self.navigationController?.presentedViewController as? ActivityIndicatorViewController else { return }
        vc.dismiss(animated: true, completion: nil)
    }
}

extension DecisionViewController: ActivityIndicatorDelegate {
    func doneDownload() {
    }
}
