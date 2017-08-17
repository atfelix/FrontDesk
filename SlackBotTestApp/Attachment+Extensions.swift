//
//  Attachment+Delivery.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-08-10.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import SKCore

extension Attachment {
    static func deliveryAttachment(for deliveryCell: DeliveryTableViewCell) -> [Attachment]? {
        guard let user = deliveryCell.user else { return nil }

        return [Attachment(fallback: self.deliveryFallback(for: user),
                           title: nil,
                           colorHex: colorHex(),
                           pretext: self.deliveryPretext(for: user),
                           fields: self.deliveryFields(for: deliveryCell))]
    }

    static func meetingAttachment(for meetingCell: MeetingTableViewCell, name: String, from company: String, with email: String) -> [Attachment]? {
        guard let user = meetingCell.user else { return nil }
        return [Attachment(fallback: self.meetingFallback(for: user),
                           title: nil,
                           colorHex: colorHex(),
                           pretext: self.meetingPretext(for: user),
                           fields: self.meetingFields(for: meetingCell,
                                                      name: name,
                                                      from: company,
                                                      with: email))]
    }

    private static func deliveryFallback(for user: User) -> String {
        guard let name = user.name else { return "banana" }
        return "Hey @\(name), you have a parcel for delivery."
    }

    private static func meetingFallback(for user: User) -> String {
        guard let userName = user.name else { return "banana" }
        return "Hey @\(userName), someone is here to see you."
    }

    private static func deliveryPretext(for user: User) -> String {
        return self.deliveryFallback(for: user)
    }

    private static func meetingPretext(for user: User) -> String {
        return self.meetingFallback(for: user)
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
}
