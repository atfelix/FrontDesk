//
//  SlackStore.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-07.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import Foundation
import SKCore
import SKWebAPI

public typealias FailureClosure = (_ error: SlackError) -> Void

public enum ParseMode: String {
    case full, none
}

class SlackStore {
    private var channels = [Channel]()
    var sortedChannels: [Channel] {
        get {
            return self.channels.sorted { $0.defaultName.lowercased() < $1.defaultName.lowercased() }
        }
    }
    private var users = Set<User>()
    var usersArray: [User] {
        get {
            return self.users.sorted { $0.defaultRealName.lowercased() < $1.defaultRealName.lowercased() }
        }
    }
    let webAPI: WebAPI


    init(token: String) {
        self.webAPI = WebAPI(token: token)
    }

    func update() {
        self.getChannels()
    }

    private func getChannels() {
        self.webAPI.channelsList(success: { [weak self] (channelArray) in
            guard let channelArray = channelArray else { return }

            self?.channels.removeAll(keepingCapacity: true)

            for channelDict in channelArray {
                let channel = Channel(channel: channelDict)
                guard let id = channel.id else { continue }

                self?.webAPI.channelInfo(id: id,
                                         success: { (channel) in
                                            self?.channels.append(channel)
                                            self?.getUsers(for: channel)
                }, failure: { (error) in
                    print(error)
                })
            }
            }, failure: nil)
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
                    print(error)
            })
        }
    }
}

extension SlackStore {
    func sendMessageToUserOrChannel(
        to user: User,
        channel: String,
        regularAttachments: [Attachment]? = nil,
        awayAttachments: [Attachment]? = nil,
        dndAttachments: [Attachment]? = nil
    ) {
        guard let userId = user.id else { return }

        self.dndInfo(user: userId, success: { (status) in
            let timestamp = Date().slackTimestamp
            if
                let dndStart = status.nextDoNotDisturbStart,
                let dndEnd = status.nextDoNotDisturbEnd,
                Double(dndStart) <= timestamp && timestamp <= Double(dndEnd) {
                self.sendMessage(channel: channel,
                                 text: "",
                                 asUser: true,
                                 linkNames: true,
                                 attachments: dndAttachments,
                                 success: nil,
                                 failure: { (error) in
                                    print(error)
                })
            }
            else {
                self.userPresence(user: userId, success: {[weak self]
                    (presence) in
                    if presence == "away" {
                        self?.sendMessage(channel: channel,
                                          text: "",
                                          asUser: true,
                                          linkNames: true,
                                          attachments: awayAttachments,
                                          success: nil,
                                          failure: { (error) in
                                            print(error)
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
                                            print(error)
                        })

                    }
                    }, failure: { (error) in
                        print(error)
                })
            }
        }, failure: { (error) in
            print(error)
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
