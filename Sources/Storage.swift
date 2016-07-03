//
//  Storage.swift
//  Features
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation
import ValueCoding

public typealias VoidBlock = () -> Void

/// Protocol to support storage
public protocol StorageAdaptor {

    /// The type of the item that requires storing
    associatedtype Item

    /// Read the items from Storage
    ///
    /// - parameter [unnamed] completion: a completion block
    /// which receives an array of Item
    func read(_: [Item] -> Void)

    /// Write the item to Storage
    ///
    /// - parameter items: the [Item] to write into storage
    /// - parameter completion: an optional completion block
    func write(items: [Item], completion: VoidBlock?)

    /// Remove all the items from Storage
    ///
    /// - parameter completion: an optional completion block
    func removeAll(completion: VoidBlock?)
}

@noreturn private func _abstractMethod(file: StaticString = #file, line: UInt = #line) {
    fatalError("Method must be overriden", file: file, line: line)
}

// MARK: - Base class for AnyStorage

public class AnyStorageBase { }

internal class AnyStorage_<Item>: AnyStorageBase, StorageAdaptor {
    override init() {
        guard self.dynamicType != AnyStorage_.self else {
            fatalError("AnyStorage_<Item> instances cannot be created. Create a subclass instead.")
        }
    }

    func read(_: [Item] -> Void) {
        _abstractMethod()
    }

    func write(items: [Item], completion: VoidBlock?) {
        _abstractMethod()
    }

    func removeAll(completion: VoidBlock?) {
        _abstractMethod()
    }
}

internal final class _StorageBox<Base: StorageAdaptor>: AnyStorage_<Base.Item> {
    var base: Base

    init(_ base: Base) {
        self.base = base
    }

    override func read(completion: [Base.Item] -> Void) {
        base.read(completion)
    }

    override func write(items: [Base.Item], completion: VoidBlock?) {
        base.write(items, completion: completion)
    }

    override func removeAll(completion: VoidBlock?) {
        base.removeAll(completion)
    }
}

public class AnyStorage<Item>: AnyStorageBase, StorageAdaptor {

    private var box: AnyStorage_<Item>

    public init<Base: StorageAdaptor where Base.Item == Item>(_ base: Base) {
        box = _StorageBox(base)
    }

    public func read(completion: [Item] -> Void) {
        box.read(completion)
    }

    public func write(items: [Item], completion: VoidBlock? = nil) {
        box.write(items, completion: completion)
    }

    public func removeAll(completion: VoidBlock? = nil) {
        box.removeAll(completion)
    }
}

// MARK: - Value Storage

public class AnyValueStorage<Item: ValueCoding where Item.Coder: NSCoding, Item == Item.Coder.ValueType>: AnyStorageBase, StorageAdaptor {

    private var box: AnyStorage<Item.Coder>

    public init<Base: StorageAdaptor where Base.Item == Item.Coder>(_ base: Base) {
        box = AnyStorage(base)
    }

    public func read(completion: [Item] -> Void) {
        box.read { completion($0.values) }
    }

    public func write(items: [Item], completion: VoidBlock? = nil) {
        box.write(items.encoded, completion: completion)
    }

    public func removeAll(completion: VoidBlock? = nil) {
        box.removeAll(completion)
    }
}

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
