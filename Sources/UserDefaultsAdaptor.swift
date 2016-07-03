//
//  UserDefaultsAdaptor.swift
//  Features
//
//  Created by Daniel Thorpe on 03/07/2016.
//
//

import Foundation

// MARK: - UserDefaultsAdaptor

public protocol UserDefaultsProtocol: class {

    func objectForKey(_: String) -> AnyObject?

    func setObject(_: AnyObject?, forKey: String)

    func removeObjectForKey(_: String)
}

extension NSUserDefaults: UserDefaultsProtocol { }

public class UserDefaultsAdaptor<Item: NSCoding>: StorageAdaptor {

    let key = "me.danthorpe.Features.UserDefaultsKey"
    public lazy var userDefaults: UserDefaultsProtocol = NSUserDefaults.standardUserDefaults()

    public func read(completion: [Item] -> Void) {
        let data = (userDefaults.objectForKey(key) as? NSData)
        let results = data.flatMap { NSKeyedUnarchiver.unarchiveObjectWithData($0) as? [Item] } ?? []
        completion(results)
    }

    public func write(items: [Item], completion: VoidBlock? = nil) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(items)
        userDefaults.setObject(data, forKey: key)
    }

    public func removeAll(completion: VoidBlock? = nil) {
        userDefaults.removeObjectForKey(key)
    }
}
