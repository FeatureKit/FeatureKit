//
//  AnyStorage.swift
//  Features
//
//  Created by Daniel Thorpe on 03/07/2016.
//
//

import Foundation
import ValueCoding

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
