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

    var slackChannel: SlackChannel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.slackChannel.update()
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
        vc.slackChannel = self.slackChannel
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Welcome to LL && DH",
                                                                style: .done,
                                                                target: nil,
                                                                action: nil)
    }
}
