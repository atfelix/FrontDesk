//
//  User+Sets.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-07.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import SKCore

extension User : Equatable, Hashable {

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int {
        get {
            return self.id?.hash ?? 0
        }
    }
}
