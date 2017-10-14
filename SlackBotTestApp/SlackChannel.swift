//
//  SlackChannel.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-07.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import Foundation
import SKCore
import SKWebAPI

typealias FailureClosure = (_ error: SlackError) -> Void

enum ParseMode: String {
    case full, none
}

typealias Team = (name: String, channelName: String, token: String)

class SlackChannel {
    var name: String
    private let channelName: String
    var channel: Channel?
    private var users = Set<User>()
    var usersArray: [User] {
        get {
            return self.users.sorted { $0.defaultRealName.lowercased() < $1.defaultRealName.lowercased() }
        }
    }
    let webAPI: WebAPI

    convenience init(team: Team) {
        self.init(name: team.name, channel: team.channelName, token: team.token)
    }

    private init(name: String, channel: String, token: String) {
        self.name = name
        self.channelName = channel
        self.webAPI = WebAPI(token: token)
    }

    func update() {
        self.channelDetails(for: self.channelName)
    }

    private func channelDetails(for channelName: String) {
        self.webAPI.channelsList(success: { (channelArray) in
            guard let channelArray = channelArray else { return }

            channelArray.forEach { channelDict in
                if
                    let name = channelDict["name"] as? String,
                    let id = channelDict["id"] as? String,
                    name == channelName {
                        self.channelInfo(for: id)
                }
            }
        }) { (error) in
            print(#file, #function, #line, error)
        }
    }

    private func channelInfo(for channelId: String) {
        self.webAPI.channelInfo(id: channelId,
                                success: { (channel) in
                                    self.channel = channel
                                    self.getUsers(for: channel)
        }) { (error) in
            print(#file, #function, #line, error)
        }
    }

    private func getUsers(for channel: Channel) {
        guard let members = channel.members else { return }

        for userIdString in members {
            self.webAPI.userInfo(id: userIdString, success: { [weak self] (user) in
                guard
                    let isBot = user.isBot,
                    let hasUser = self?.users.contains(user),
                    !isBot && !hasUser else {
                        return
                }

                self?.users.insert(user)
                }, failure: { (error) in
                    print(#file, #function, #line, error)
            })
        }
    }
}

extension SlackChannel {
    func sendMessage(
        to user: User,
        regularAttachments: [Attachment]? = nil,
        awayAttachments: [Attachment]? = nil,
        dndAttachments: [Attachment]? = nil
    ) {
        guard
            let userId = user.id,
            let channelName = self.channel?.name else { return }

        self.dndInfo(user: userId, success: { (status) in
            let timestamp = Date().slackTimestamp
            if
                let dndStart = status.nextDoNotDisturbStart,
                let dndEnd = status.nextDoNotDisturbEnd,
                Double(dndStart) <= timestamp && timestamp <= Double(dndEnd) {
                self.sendMessage(channel: channelName,
                                 text: "",
                                 asUser: true,
                                 linkNames: true,
                                 attachments: dndAttachments,
                                 success: nil,
                                 failure: { (error) in
                                    print(#file, #function, #line, error)
                })
            }
            else {
                self.userPresence(user: userId, success: {[weak self]
                    (presence) in
                    if presence == "away" {
                        self?.sendMessage(channel: channelName,
                                          text: "",
                                          asUser: true,
                                          linkNames: true,
                                          attachments: awayAttachments,
                                          success: nil,
                                          failure: { (error) in
                                            print(#file, #function, #line, error)
                        })
                    }
                    else {
                        self?.sendMessage(channel: "@\(userId)",
                                          text: "",
                                          asUser: true,
                                          linkNames: true,
                                          attachments: regularAttachments,
                                          success: nil,
                                          failure: { error in
                                            print(#file, #function, #line, error)
                        })

                    }
                    }, failure: { (error) in
                        print(#file, #function, #line, error)
                })
            }
        }, failure: { (error) in
            print(#file, #function, #line, error)
        })
    }

    private func sendMessage(
        channel: String,
        text: String,
        username: String? = nil,
        asUser: Bool? = nil,
        linkNames: Bool? = nil,
        attachments: [Attachment?]? = nil,
        unfurlLinks: Bool? = nil,
        unfurlMedia: Bool? = nil,
        iconURL: String? = nil,
        iconEmoji: String? = nil,
        success: (((ts: String?, channel: String?)) -> Void)?,
        failure: FailureClosure?
    ) {
        self.webAPI.sendMessage(channel: channel,
                                text: text,
                                username: username,
                                asUser: asUser,
                                linkNames: linkNames,
                                attachments: attachments,
                                unfurlLinks: unfurlLinks,
                                unfurlMedia: unfurlMedia,
                                iconURL: iconURL,
                                iconEmoji: iconEmoji,
                                success: success,
                                failure: failure)
        sleep(1)
    }

    private func userPresence(
        user: String,
        success: ((_ presence: String?) -> Void)?,
        failure: FailureClosure?
    ) {
        self.webAPI.userPresence(user: user,
                                 success: success,
                                 failure: failure)
        sleep(1)
    }

    private func dndInfo(
        user: String? = nil,
        success: ((_ status: DoNotDisturbStatus) -> Void)?,
        failure: FailureClosure?
    ) {
        self.webAPI.dndInfo(user: user,
                            success: success,
                            failure: failure)
        sleep(1)
    }
}
