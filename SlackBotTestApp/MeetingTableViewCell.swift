//
//  MeetingTableViewCell.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKCore

class MeetingTableViewCell: UITableViewCell, SlackTableViewCell {

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
        self.textLabel?.text = self.user?.profile?.realName
    }
}
