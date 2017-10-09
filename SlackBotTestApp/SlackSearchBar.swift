//
//  SlackSearchBar.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-10-09.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit

class SlackSearchBar: UISearchBar {
    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        super.setShowsCancelButton(false, animated: animated)
    }
}
