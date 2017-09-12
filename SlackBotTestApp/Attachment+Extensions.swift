//
//  Attachment+Delivery.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-10.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import SKCore

extension Attachment {
    static func regularDeliveryAttachment(for deliveryCell: DeliveryTableViewCell) -> [Attachment]? {
        guard let user = deliveryCell.user else { return nil }

        return [Attachment(fallback: self.deliveryFallback(for: user),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.deliveryPretext(for: user),
                           fields: self.deliveryFields(for: deliveryCell))]
    }

    static func awayDeliveryAttachement(for deliveryCell: DeliveryTableViewCell, channel: String) -> [Attachment]? {
        guard let user = deliveryCell.user else { return nil }

        return [Attachment(fallback: self.awayDeliveryFallback(for: user, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.awayDeliveryPretext(for: user, channel: channel),
                           fields: self.deliveryFields(for: deliveryCell))]
    }

    static func dndDeliveryAttachement(for deliveryCell: DeliveryTableViewCell, channel: String) -> [Attachment]? {
        guard let user = deliveryCell.user else { return nil }

        return [Attachment(fallback: self.dndDeliveryFallback(for: user, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.dndDeliveryPretext(for: user, channel: channel),
                           fields: self.deliveryFields(for: deliveryCell))]
    }

    static func meetingAttachment(for meetingCell: MeetingTableViewCell, name: String, from company: String, with email: String) -> [Attachment]? {
        guard let user = meetingCell.user else { return nil }
        return [Attachment(fallback: self.meetingFallback(for: user),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.meetingPretext(for: user),
                           fields: self.meetingFields(for: meetingCell,
                                                      name: name,
                                                      from: company,
                                                      with: email))]
    }

    static func awayMeetingAttachment(for meetingCell: MeetingTableViewCell, channel: String, name: String, from company: String, with email: String) -> [Attachment]? {
        guard let user = meetingCell.user else { return nil }
        return [Attachment(fallback: self.awayMeetingFallback(for: user, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.awayMeetingPretext(for: user, channel: channel),
                           fields: self.channelMeetingFields(for: meetingCell,
                                                             name: name,
                                                             from: company,
                                                             with: email))]
    }

    static func dndMeetingAttachment(for meetingCell: MeetingTableViewCell, channel: String, name: String, from company: String, with email: String) -> [Attachment]? {
        guard let user = meetingCell.user else { return nil }
        return [Attachment(fallback: self.dndMeetingFallback(for: user, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.dndMeetingPretext(for: user, channel: channel),
                           fields: self.channelMeetingFields(for: meetingCell,
                                                             name: name,
                                                             from: company,
                                                             with: email))]
    }

    private static func deliveryFallback(for user: User) -> String {
        guard let userName = user.name else { return "banana" }
        return "Hey @\(userName), you have a parcel for delivery."
    }

    private static func meetingFallback(for user: User) -> String {
        guard let userName = user.name else { return "banana" }
        return "Hey @\(userName), someone is here to see you."
    }

    private static func awayDeliveryFallback(for user: User, channel: String) -> String {
        guard let userName = user.name else { return "banana" }
        return "Hey everybody, @\(userName) has a parcel delivery but is away."
    }

    private static func awayMeetingFallback(for user: User, channel: String) -> String {
        guard let userName = user.name else { return "banana" }
        return "Hey everybody, someone is here to see @\(userName) but is away."
    }

    private static func dndDeliveryFallback(for user: User, channel: String) -> String {
        guard let userName = user.name else { return "banana" }
        return "Hey everybody, @\(userName) has a parcel delivery but doesn't want to be disturbed."
    }

    private static func dndMeetingFallback(for user: User, channel: String) -> String {
        guard let userName = user.name else { return "banana" }
        return "Hey everybody, someone is here to see @\(userName) who doesn't want to be disturbed."
    }

    private static func deliveryPretext(for user: User) -> String {
        return self.deliveryFallback(for: user)
    }

    private static func meetingPretext(for user: User) -> String {
        return self.meetingFallback(for: user)
    }

    private static func awayMeetingPretext(for user: User, channel: String) -> String {
        return self.awayMeetingFallback(for: user, channel: channel)
    }

    private static func awayDeliveryPretext(for user: User, channel: String) -> String {
        return self.awayDeliveryFallback(for: user, channel: channel)
    }

    private static func dndDeliveryPretext(for user: User, channel: String) -> String {
        return self.dndDeliveryFallback(for: user, channel: channel)
    }

    private static func dndMeetingPretext(for user: User, channel: String) -> String {
        return self.dndMeetingFallback(for: user, channel: channel)
    }

    private static func colorHex() -> String {
        return "#888888"
    }

    private static func deliveryFields(for deliveryCell: DeliveryTableViewCell) -> [AttachmentField] {
        return [AttachmentField(title: "Left at Front Door",
                                value: (deliveryCell.leftAtFrontDeskSwitch.isOn) ? "Yes" : "No",
                                short: true),
                AttachmentField(title: "Needs Signature",
                                value: (deliveryCell.signatureRequiredSwitch.isOn) ? "Yes" : "No",
                                short: true)]
    }

    private static func meetingFields(for meetingCell: MeetingTableViewCell, name: String, from company: String, with email: String) -> [AttachmentField] {
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

    private static func channelMeetingFields(for meetingCell: MeetingTableViewCell, name: String, from company: String, with email: String) -> [AttachmentField] {
        return self.meetingFields(for: meetingCell,
                                  name: name,
                                  from: company,
                                  with: email)
    }
}
