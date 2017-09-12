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
        guard
            let user = deliveryCell.user,
            let userName = user.name else {
                return nil
        }

        return [Attachment(fallback: self.deliveryFallback(userName: userName),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.deliveryPretext(userName: userName),
                           fields: self.deliveryFields(for: deliveryCell))]
    }

    static func awayDeliveryAttachement(for deliveryCell: DeliveryTableViewCell, channel: String) -> [Attachment]? {
        guard
            let user = deliveryCell.user,
            let userName = user.name else {
                return nil
        }

        return [Attachment(fallback: self.awayDeliveryFallback(userName: userName, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.awayDeliveryPretext(userName: userName, channel: channel),
                           fields: self.deliveryFields(for: deliveryCell))]
    }

    static func dndDeliveryAttachement(for deliveryCell: DeliveryTableViewCell, channel: String) -> [Attachment]? {
        guard
            let user = deliveryCell.user,
            let userName = user.name else {
                return nil
        }

        return [Attachment(fallback: self.dndDeliveryFallback(userName: userName, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.dndDeliveryPretext(userName: userName, channel: channel),
                           fields: self.deliveryFields(for: deliveryCell))]
    }

    static func meetingAttachment(for meetingCell: MeetingTableViewCell, name: String, from company: String, with email: String) -> [Attachment]? {
        guard
            let user = meetingCell.user,
            let userName = user.name else {
                return nil
        }

        return [Attachment(fallback: self.meetingFallback(userName: userName),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.meetingPretext(userName: userName),
                           fields: self.meetingFields(for: meetingCell,
                                                      name: name,
                                                      from: company,
                                                      with: email))]
    }

    static func awayMeetingAttachment(for meetingCell: MeetingTableViewCell, channel: String, name: String, from company: String, with email: String) -> [Attachment]? {
        guard
            let user = meetingCell.user,
            let userName = user.name else {
                return nil
        }

        return [Attachment(fallback: self.awayMeetingFallback(userName: userName, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.awayMeetingPretext(userName: userName, channel: channel),
                           fields: self.channelMeetingFields(for: meetingCell,
                                                             name: name,
                                                             from: company,
                                                             with: email))]
    }

    static func dndMeetingAttachment(for meetingCell: MeetingTableViewCell, channel: String, name: String, from company: String, with email: String) -> [Attachment]? {
        guard
            let user = meetingCell.user,
            let userName = user.name else {
                return nil
        }

        return [Attachment(fallback: self.dndMeetingFallback(userName: userName, channel: channel),
                           title: nil,
                           colorHex: self.colorHex(),
                           pretext: self.dndMeetingPretext(userName: userName, channel: channel),
                           fields: self.channelMeetingFields(for: meetingCell,
                                                             name: name,
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
