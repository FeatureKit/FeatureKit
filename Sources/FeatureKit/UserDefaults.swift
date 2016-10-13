//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation

public protocol UserDefaultsProtocol: class {

    func object(forKey defaultName: String) -> Any?

    func set(_ value: Any?, forKey defaultName: String)

    func removeObject(forKey defaultName: String)

    func dictionaryRepresentation() -> [String : Any]
}

extension UserDefaults: UserDefaultsProtocol { }

public class UserDefaultsStorage<K, V>: SyncStorageProtocol where K: Hashable, K: CustomStringConvertible, V: NSCoding {

    public typealias Key = K
    public typealias Value = V

    public let group: String?
    public let prefix: String

    public lazy var userDefaults: UserDefaultsProtocol = {
        return UserDefaults(suiteName: self.group) ?? UserDefaults.standard
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
            let data = (userDefaults.object(forKey: prefixed(key)) as? Data)
            return data.flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) as? Value }
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: prefixed(key)); return
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            userDefaults.set(data, forKey: prefixed(key))
        }
    }

    public var values: AnyRandomAccessCollection<Value> {
        return AnyRandomAccessCollection(userDefaults.dictionaryRepresentation().values.lazy.flatMap { obj in
            guard let data = obj as? Data else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? Value
        })
    }

    public func removeAll() {
        for key in userDefaults.dictionaryRepresentation().keys.filter({ $0.hasPrefix(self.prefix) }) {
            userDefaults.removeObject(forKey: key)
        }
    }
}
