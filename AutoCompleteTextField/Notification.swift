import AppKit


public extension Notification.Name {
    
    static let updateAccount             = Notification.Name( "updateAccount")
}

extension NotificationCenter {
    
    // Send(Post) Notification
    static func send(_ key: Notification.Name) {
        self.default.post(
            name: key,
            object: nil
        )
    }
    
    // Receive(addObserver) Notification
    static func receive(instance: Any, selector: Selector, name: Notification.Name) {
        self.default.addObserver(
            instance,
            selector: selector,
            name: name,
            object: nil
        )
    }
    
    // Remove(removeObserver) Notification
    static func remove( instance: Any, name: Notification.Name  ) {
        self.default.removeObserver(
            instance,
            name: name,
            object: nil
        )
    }

}
