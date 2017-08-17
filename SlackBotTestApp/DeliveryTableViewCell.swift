//
//  DeliveryTableViewCell.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-02.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKCore

class DeliveryTableViewCell: UITableViewCell, SlackTableViewCell {

    @IBOutlet weak var leftAtFrontDeskSwitch: UISwitch!
    @IBOutlet weak var signatureRequiredSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!

    var _user: User?
    var user: User? {
        get {
            return self._user
        }
        set {
            self._user = newValue
        }
    }
    
    func displayCell() {
        self.nameLabel.text = self.user?.profile?.realName
    }
}
