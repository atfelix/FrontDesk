//
//  SlackStore.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-07.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import SKCore
import SKWebAPI

class SlackStore {
    private var channels = [Channel]()
    var sortedChannels: [Channel] {
        get {
            return self.channels.sorted { ($0.name)! < ($1.name)! }
        }
    }
    private var users = Set<User>()
    var usersArray: [User] {
        get {
            return self.users.sorted { ($0.profile?.realName)! < ($1.profile?.realName)! }
        }
    }
    let webAPI: WebAPI

    init(token: String) {
        self.webAPI = WebAPI(token: token)
        self.getChannels()
    }

    private func getChannels() {
        self.webAPI.channelsList(success: { [weak self] (channelArray) in
            for channelDict in channelArray! {
                let channel = Channel(channel: channelDict)
                self?.webAPI.channelInfo(id: channel.id!,
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
                print("user: \(userIdString)")
                }, failure: { (error) in
                    print(error)
            })
        }
    }
}
