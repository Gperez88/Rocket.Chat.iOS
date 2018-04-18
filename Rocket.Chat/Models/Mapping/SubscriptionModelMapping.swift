//
//  SubscriptionModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Subscription: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].stringValue
        }

        self.rid = values["rid"].stringValue
        self.name = values["name"].stringValue
        self.fname = values["fname"].stringValue
        self.unread = values["unread"].int ?? 0
        self.open = values["open"].bool ?? false
        self.alert = values["alert"].bool ?? false
        self.favorite = values["f"].bool ?? false

        if let typeString = values["t"].string {
            self.type = SubscriptionType(rawValue: typeString) ?? .channel
        }

        if self.type == .directMessage {
            let userId = values["u"]["_id"].stringValue
            self.otherUserId = self.rid.replacingOccurrences(of: userId, with: "")
        }

        if let createdAt = values["ts"]["$date"].double {
            self.createdAt = Date.dateFromInterval(createdAt)
        }

        if let lastSeen = values["ls"]["$date"].double {
            self.lastSeen = Date.dateFromInterval(lastSeen)
        }

        mapNotifications(values)
    }

    func mapNotifications(_ values: JSON) {
        self.disableNotifications = values["disableNotifications"].bool ?? false
        self.hideUnreadStatus = values["hideUnreadStatus"].bool ?? false
        if let desktopNotificationsString = values["desktopNotifications"].string {
            self.desktopNotifications = SubscriptionNotificationsStatus(rawValue: desktopNotificationsString) ?? .default
        }

        if let audioNotificationsString = values["audioNotifications"].string {
            self.audioNotifications = SubscriptionNotificationsStatus(rawValue: audioNotificationsString) ?? .default
        }

        if let mobilePushNotificationsString = values["mobilePushNotifications"].string {
            self.mobilePushNotifications = SubscriptionNotificationsStatus(rawValue: mobilePushNotificationsString) ?? .default
        }

        if let emailNotificationsString = values["emailNotifications"].string {
            self.emailNotifications = SubscriptionNotificationsStatus(rawValue: emailNotificationsString) ?? .default
        }

        if let audioNotificationValueString = values["audioNotificationValue"].string {
            self.audioNotificationValue = SubscriptionNotificationsAudioValue(rawValue: audioNotificationValueString) ?? .default
        }

        if let duration = values["desktopNotificationDuration"].int {
            self.desktopNotificationDuration = duration
        }
    }

    func mapRoom(_ values: JSON) {
        self.roomDescription = values["description"].stringValue
        self.roomTopic = values["topic"].stringValue

        self.roomMuted.removeAll()
        if let roomMuted = values["muted"].array?.compactMap({ $0.string }) {
            self.roomMuted.append(objectsIn: roomMuted)
        }

        if let readOnly = values["ro"].bool {
            self.roomReadOnly = readOnly
        }

        if let ownerId = values["u"]["_id"].string {
            self.roomOwnerId = ownerId
        }
    }
}
