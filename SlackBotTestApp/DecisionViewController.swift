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

    var channelStore: ChannelStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
    }

    private func setupButtons() {
        self.setupDeliveryButton()
        self.setupMeetingButton()
    }

    private func setupDeliveryButton(){
        self.setupDecisionButton(button: self.deliveryButton,
                                 title: "I have a parcel for ...",
                                 action: #selector(DecisionViewController.deliveryButtonClicked(sender:)))
    }

    private func setupMeetingButton() {
        self.setupDecisionButton(button: self.meetingButton,
                                 title: "I have a meeting with ...",
                                 action: #selector(DecisionViewController.meetingButtonClicked(sender:)))
    }

    private func setupDecisionButton(button: UIButton, title: String, action: Selector) {
        UIButton.setupDecisionButton(button: button, title: title)
        button.addTarget(self,
                         action: action,
                         for: .touchUpInside)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as
    }

    func deliveryButtonClicked(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeliveryViewController") as! DeliveryViewController
        vc.channelStore = self.channelStore
        vc.webAPI = self.channelStore.webAPI
        vc.filteredUsers = self.channelStore.usersArray
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func meetingButtonClicked(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MeetingViewController") as! MeetingViewController
        vc.channelStore = self.channelStore
        vc.webAPI = self.channelStore.webAPI
        vc.filteredUsers = self.channelStore.usersArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
