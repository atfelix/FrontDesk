//
//  Attachment+Delivery.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-10.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import SKCore

extension Attachment {
    static func regularDeliveryAttachment(for user: User, leftAtFrontDesk: Bool, signatureRequired: Bool) -> [Attachment]? {
        guard let userName = user.name else { return nil }

        return [Attachment(fallback: self.deliveryFallback(userName: userName),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.deliveryPretext(userName: userName),
                           fields: self.deliveryFields(leftAtFrontDesk: leftAtFrontDesk, signatureRequired: signatureRequired))]
    }

    static func awayDeliveryAttachement(for user: User, leftAtFrontDesk: Bool, signatureRequired: Bool, channel: String) -> [Attachment]? {
        guard let userName = user.name else { return nil }

        return [Attachment(fallback: self.awayDeliveryFallback(userName: userName, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.awayDeliveryPretext(userName: userName, channel: channel),
                           fields: self.deliveryFields(leftAtFrontDesk: leftAtFrontDesk, signatureRequired: signatureRequired))]
    }

    static func dndDeliveryAttachement(for user: User, leftAtFrontDesk: Bool, signatureRequired: Bool, channel: String) -> [Attachment]? {
        guard let userName = user.name else { return nil }

        return [Attachment(fallback: self.dndDeliveryFallback(userName: userName, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.dndDeliveryPretext(userName: userName, channel: channel),
                           fields: self.deliveryFields(leftAtFrontDesk: leftAtFrontDesk, signatureRequired: signatureRequired))]
    }

    static func meetingAttachment(for user: User, name: String, from company: String, with email: String) -> [Attachment]? {
        guard let userName = user.name else { return nil }

        return [Attachment(fallback: self.meetingFallback(userName: userName),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.meetingPretext(userName: userName),
                           fields: self.meetingFields(for: name,
                                                      from: company,
                                                      with: email))]
    }

    static func awayMeetingAttachment(for user: User, team: Team, name: String, from company: String, with email: String) -> [Attachment]? {
        guard let userName = user.name else { return nil }

        return [Attachment(fallback: self.awayMeetingFallback(userName: userName, channel: team.channelName),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.awayMeetingPretext(userName: userName, channel: team.channelName),
                           fields: self.channelMeetingFields(for: name,
                                                             from: company,
                                                             with: email))]
    }

    static func dndMeetingAttachment(for user: User, team: Team, name: String, from company: String, with email: String) -> [Attachment]? {
        guard let userName = user.name else { return nil }

        return [Attachment(fallback: self.dndMeetingFallback(userName: userName, channel: team.channelName),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.dndMeetingPretext(userName: userName, channel: team.channelName),
                           fields: self.channelMeetingFields(for: name,
                                                             from: company,
                                                             with: email))]
    }

    private static func deliveryFallback(userName: String) -> String {
        return "Hey @\(userName), you have a parcel for delivery."
    }

    private static func meetingFallback(userName: String) -> String {
        return "Hey @\(userName), someone is here to see you."
    }

    private static func awayDeliveryFallback(userName: String, channel: String) -> String {
        return "Hey everybody, @\(userName) has a parcel delivery but is away."
    }

    private static func awayMeetingFallback(userName: String, channel: String) -> String {
        return "Hey everybody, someone is here to see @\(userName) but is away."
    }

    private static func dndDeliveryFallback(userName: String, channel: String) -> String {
        return "Hey everybody, @\(userName) has a parcel delivery but doesn't want to be disturbed."
    }

    private static func dndMeetingFallback(userName: String, channel: String) -> String {
        return "Hey everybody, someone is here to see @\(userName) who doesn't want to be disturbed."
    }

    private static func deliveryPretext(userName: String) -> String {
        return self.deliveryFallback(userName: userName)
    }

    private static func meetingPretext(userName: String) -> String {
        return self.meetingFallback(userName: userName)
    }

    private static func awayMeetingPretext(userName: String, channel: String) -> String {
        return self.awayMeetingFallback(userName: userName, channel: channel)
    }

    private static func awayDeliveryPretext(userName: String, channel: String) -> String {
        return self.awayDeliveryFallback(userName: userName, channel: channel)
    }

    private static func dndDeliveryPretext(userName: String, channel: String) -> String {
        return self.dndDeliveryFallback(userName: userName, channel: channel)
    }

    private static func dndMeetingPretext(userName: String, channel: String) -> String {
        return self.dndMeetingFallback(userName: userName, channel: channel)
    }

    private static func colorHex() -> String {
        return "#888888"
    }

    private static func deliveryFields(leftAtFrontDesk: Bool, signatureRequired: Bool) -> [AttachmentField] {
        return [AttachmentField(title: "Left at Front Desk",
                                value: (leftAtFrontDesk) ? "Yes" : "No",
                                short: true),
                AttachmentField(title: "Needs Signature",
                                value: (signatureRequired) ? "Yes" : "No",
                                short: true)]
    }

    private static func meetingFields(for name: String, from company: String, with email: String) -> [AttachmentField] {
        return [AttachmentField(title: "Who:",
                                value: name,
                                short: true),
                AttachmentField(title: "From:",
                                value: company,
                                short: true),
                AttachmentField(title: "Email:",
                                value: email,
                                short: true)]
    }

    private static func channelMeetingFields(for name: String, from company: String, with email: String) -> [AttachmentField] {
        return self.meetingFields(for: name,
                                  from: company,
                                  with: email)
    }
}
