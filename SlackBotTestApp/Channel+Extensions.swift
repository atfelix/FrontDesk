//
//  Channel+Extensions.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-18.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import SKCore

extension Channel {
    var defaultName: String {
        get {
            return self.name ?? "# NO CHANNEL NAME"
        }
    }
}
