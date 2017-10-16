//
//  SlackChannelManager.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-10-09.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import Foundation
import SKCore

class SlackChannelManager {
    let teams: [Team]
    let channels: [SlackChannel]
    private var numberOfDownloads = 0 {
        didSet {
            if self.numberOfDownloads == 0 {
                NotificationCenter.default.post(name: NSNotification.Name("SlackChannelManagerDownloadDidFinish"), object: nil)
            }
        }
    }

    deinit {
        self.deregisterNotifications()
    }

    private func deregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SlackChannelManager.downloadCompleted),
                                               name: NSNotification.Name("SlackChannelDidFinishDownload"),
                                               object: nil)
    }

    init(teams: [Team]) {
        self.teams = teams
        self.channels = teams.map { SlackChannel(team: $0) }
        self.registerNotifications()
    }

    func update() {
        self.numberOfDownloads = self.teams.count
        self.channels.forEach { $0.update() }
    }

    func slackChannel(for team: Team) -> SlackChannel? {
        return self.channels.first { $0.name == team.name }
    }

    func slackChannel(for teamName: String) -> SlackChannel? {
        return self.channels.first { $0.name == teamName }
    }

    func slackTeam(for team: Team) -> Team? {
        return self.teams.first { $0.name == team.name }
    }

    func slackTeam(for teamName: String) -> Team? {
        return self.teams.first { $0.name == teamName }
    }

    func users(for team: Team) -> [User]? {
        guard let channel = self.slackChannel(for: team) else { return nil }

        return channel.users.sorted { $0.0.defaultRealName < $0.1.defaultRealName }
    }

    @objc func downloadCompleted() {
        self.numberOfDownloads -= 1
    }
}

extension SlackChannelManager {
    func sendMessage(
        to users: [User],
        on team: Team,
        regularAttachments: [Attachment]? = nil,
        awayAttachments: [Attachment]? = nil,
        dndAttachments: [Attachment]? = nil
    ) {
        guard let slackChannel = self.slackChannel(for: team) else { return }

        users.forEach { slackChannel.sendMessage(to: $0,
                                                 regularAttachments: regularAttachments,
                                                 awayAttachments: awayAttachments,
                                                 dndAttachments: dndAttachments) }
    }
}
