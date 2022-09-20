//
//  NotificationService.swift
//  NotificationService
//
//  Copyright © 2016년 kissoft. All rights reserved.
//

import UserNotifications

class NotificationService: fingerNotificationService {
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self .disableSyncBadge()
        
        super.didReceive(request, withContentHandler: contentHandler)
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        super .serviceExtensionTimeWillExpire()
    }

}
