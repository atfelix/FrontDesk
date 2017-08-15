//
//  DeliveryTableViewCell.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-02.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKCore

class DeliveryTableViewCell: UITableViewCell {

    @IBOutlet weak var leftAtFrontDeskSwitch: UISwitch!
    @IBOutlet weak var signatureRequiredSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!

    var user: User!
    
    func displayCell() {
        self.nameLabel.text = user.profile?.realName
    }
}
