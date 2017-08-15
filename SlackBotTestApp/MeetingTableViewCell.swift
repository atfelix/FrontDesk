//
//  MeetingTableViewCell.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKCore

class MeetingTableViewCell: UITableViewCell {

    var user: User!

    func displayCell() {
        self.textLabel?.text = user.profile?.realName
    }
}
