import Foundation

open class SwiftEventBus {
    
    struct Static {
        static let instance = SwiftEventBus()
        static let queue = DispatchQueue(label: "com.cesarferreira.SwiftEventBus", attributes: [])
    }
    
    struct NamedObserver {
        let observer: NSObjectProtocol
        let name: String
    }
    
    var cache = [UInt:[NamedObserver]]()
    
    
    ////////////////////////////////////
    // Publish
    ////////////////////////////////////
    
    open class func post(message: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: nil)
    }
    
    open class func post(message: String, sender: Any?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: sender)
    }
    
    open class func post(message: String, sender: NSObject?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: sender)
    }
    
    open class func post(message: String, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: nil, userInfo: userInfo)
    }
    
    open class func post(message: String, sender: Any?, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: sender, userInfo: userInfo)
    }
    
    open class func postToMainThread(message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: nil)
        }
    }
    
    open class func postToMainThread(message: String, sender: Any?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: sender)
        }
    }
    
    open class func postToMainThread(message: String, sender: NSObject?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: sender)
        }
    }
    
    open class func postToMainThread(message: String, userInfo: [AnyHashable: Any]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: nil, userInfo: userInfo)
        }
    }
    
    open class func postToMainThread(message: String, sender: Any?, userInfo: [AnyHashable: Any]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: message), object: sender, userInfo: userInfo)
        }
    }
    

    
    ////////////////////////////////////
    // Subscribe
    ////////////////////////////////////
    
    open class func on(notify target: AnyObject, name: String, sender: Any?, queue: OperationQueue?, handler: @escaping ((Notification!) -> Void)) -> NSObjectProtocol {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: sender, queue: queue, using: handler)
        let namedObserver = NamedObserver(observer: observer, name: name)
        
        Static.queue.sync {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers + [namedObserver]
            } else {
                Static.instance.cache[id] = [namedObserver]
            }
        }
        
        return observer
    }
    
    open class func onMainThread(notify target: AnyObject, name: String, handler: @escaping ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(notify: target, name: name, sender: nil, queue: OperationQueue.main, handler: handler)
    }
    
    open class func onMainThread(notify target: AnyObject, name: String, sender: Any?, handler: @escaping ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(notify: target, name: name, sender: sender, queue: OperationQueue.main, handler: handler)
    }
    
    open class func onBackgroundThread(notify target: AnyObject, name: String, handler: @escaping ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(notify: target, name: name, sender: nil, queue: OperationQueue(), handler: handler)
    }
    
    open class func onBackgroundThread(notify target: AnyObject, name: String, sender: Any?, handler: @escaping ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(notify: target, name: name, sender: sender, queue: OperationQueue(), handler: handler)
    }
    
    ////////////////////////////////////
    // Unregister
    ////////////////////////////////////
    
    open class func unregister(_ target: AnyObject) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default
        
        Static.queue.sync {
            if let namedObservers = Static.instance.cache.removeValue(forKey: id) {
                for namedObserver in namedObservers {
                    center.removeObserver(namedObserver.observer)
                }
            }
        }
    }
    
    open class func unregister(_ target: AnyObject, name: String) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default
        
        Static.queue.sync {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers.filter({ (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.name == name {
                        center.removeObserver(namedObserver.observer)
                        return false
                    } else {
                        return true
                    }
                })
            }
        }
    }
    
}
