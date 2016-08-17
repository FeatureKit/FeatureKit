//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation

public protocol UserDefaultsProtocol: class {

    func objectForKey(_: String) -> AnyObject?

    func setObject(_: AnyObject?, forKey: String)

    func removeObjectForKey(_: String)

    func dictionaryRepresentation() -> [String: AnyObject]
}

extension NSUserDefaults: UserDefaultsProtocol { }

public class UserDefaultsStorage<K, V where K: Hashable, K: CustomStringConvertible, V: NSCoding>: SyncStorageProtocol {

    public typealias Key = K
    public typealias Value = V

    public let group: String?
    public let prefix: String

    public lazy var userDefaults: UserDefaultsProtocol = {
        return NSUserDefaults(suiteName: self.group) ?? NSUserDefaults.standardUserDefaults()
    }()

    private lazy var prefixed: (Key) -> String = {
        let p = self.prefix
        return { "\(p).\($0.description)" }
    }()

    public init(group: String? = nil, prefix: String = "run.kit.feature") {
        self.group = group
        self.prefix = !prefix.isEmpty ? prefix : "run.kit.feature"
    }

    public subscript(key: Key) -> V? {
        get {
            let data = (userDefaults.objectForKey(prefixed(key)) as? NSData)
            return data.flatMap { NSKeyedUnarchiver.unarchiveObjectWithData($0) as? Value }
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObjectForKey(prefixed(key)); return
            }
            let data = NSKeyedArchiver.archivedDataWithRootObject(newValue)
            userDefaults.setObject(data, forKey: prefixed(key))
        }
    }

    public var values: AnyRandomAccessCollection<Value> {
        return AnyRandomAccessCollection(userDefaults.dictionaryRepresentation().values.lazy.flatMap { obj in
            guard let data = obj as? NSData else { return nil }
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Value
        })
    }

    public func removeAll() {
        for key in userDefaults.dictionaryRepresentation().keys.filter({ $0.hasPrefix(self.prefix) }) {
            userDefaults.removeObjectForKey(key)
        }
    }
}
