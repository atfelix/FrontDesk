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

    var deliveryButton: UIButton!
    var meetingButton: UIButton!

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
        self.deliveryButton = UIButton.decisionButton(in: self.view,
                                                      title: "I have a parcel for ...",
                                                      y: 3 * self.view.bounds.height / 4)
        self.deliveryButton.addTarget(self,
                                      action: #selector(DecisionViewController.deliveryButtonClicked(sender:)),
                                      for: .touchUpInside)
    }

    private func setupMeetingButton() {
        self.meetingButton = UIButton.decisionButton(in: self.view,
                                                     title: "I have a meeting with ...",
                                                     y: self.view.bounds.height / 4)
        self.meetingButton.addTarget(self,
                                     action: #selector(DecisionViewController.meetingButtonClicked(sender:)),
                                     for: .touchUpInside)
    }

    func deliveryButtonClicked(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeliveryViewController") as! DeliveryViewController
        vc.channelStore = self.channelStore
        vc.webAPI = self.channelStore.webAPI
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func meetingButtonClicked(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MeetingViewController") as! MeetingViewController
        vc.channelStore = self.channelStore
        vc.webAPI = self.channelStore.webAPI
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
