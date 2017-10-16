//
//  String+Validation.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-09-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import Foundation

extension String {
    static func isValid(email: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]",
                                                   options: .caseInsensitive) else {
            return false
        }

        let numMatches = regex.numberOfMatches(in: email,
                                               options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                               range: NSRange(location: 0,
                                                              length: email.characters.count))
        return numMatches == 1
    }
}
