//
//  SlackChannelManager.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-10-09.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import Foundation
import SKCore

struct SlackChannelManager {
    let channels: [SlackChannel]

    init(teams: [Team]) {
        self.channels = teams.map { SlackChannel(team: $0) }
    }

    func update() {
        self.channels.forEach { $0.update() }
    }

    func slackChannel(for teamName: String) -> SlackChannel? {
        return self.channels.first { $0.name == teamName }
    }
}

extension SlackChannelManager {
    func sendMessage(
        to users: [User],
        on teamName: String,
        regularAttachments: [Attachment]? = nil,
        awayAttachments: [Attachment]? = nil,
        dndAttachments: [Attachment]? = nil
    ) {
        guard let slackChannel = self.slackChannel(for: teamName) else { return }

        users.forEach { slackChannel.sendMessage(to: $0,
                                                 regularAttachments: regularAttachments,
                                                 awayAttachments: awayAttachments,
                                                 dndAttachments: dndAttachments) }
    }
}
