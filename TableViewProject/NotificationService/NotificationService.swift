import UserNotifications

class NotificationService:fingerNotificationService {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        self .disableSyncBadge()

        super.didReceive(request, withContentHandler: contentHandler)
    }

    override func serviceExtensionTimeWillExpire() {
        super .serviceExtensionTimeWillExpire()
    }

}
