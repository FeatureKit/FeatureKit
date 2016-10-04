//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation
import ValueCoding

internal func _abstractMethod(file: StaticString = #file, line: UInt = #line) -> Never  {
    fatalError("Method must be overriden", file: file, line: line)
}

public typealias VoidBlock = () -> Void

/// Protocol to support storage

public protocol StorageProtocol {
    associatedtype Key: Hashable
    associatedtype Value
}

public protocol SyncStorageProtocol: StorageProtocol {

    subscript(key: Key) -> Value? { get set }

    var values: AnyRandomAccessCollection<Value> { get }

    func removeAll()
}

public protocol AsyncStorageProtocol: StorageProtocol {

    func asyncRead(key: Key, _: (Value?) -> Void)

    func asyncWrite(value: Value, to: Key, _: (() -> Void)?)

    func asyncRemove(key: Key, _: ((Value?) -> Void)?)
}

fileprivate class AnyStorage_<K: Hashable, V>: SyncStorageProtocol, AsyncStorageProtocol {
    typealias Key = K
    typealias Value = V

    fileprivate subscript(key: Key) -> Value? {
        get {
            _abstractMethod()
        }
        set {
            _abstractMethod()
        }
    }

    fileprivate var values: AnyRandomAccessCollection<Value> {
        _abstractMethod()
    }

    fileprivate func removeAll() {
        _abstractMethod()
    }

    fileprivate func asyncRead(key: Key, _: (Value?) -> Void) {
        _abstractMethod()
    }

    fileprivate func asyncWrite(value: Value, to: Key, _: (() -> Void)?) {
        _abstractMethod()
    }

    fileprivate func asyncRemove(key: Key, _: ((Value?) -> Void)?) {
        _abstractMethod()
    }
}

private final class AnyStorageSyncBox<Base: SyncStorageProtocol>: AnyStorage_<Base.Key, Base.Value> {

    private var base: Base

    init(_ base: Base) {
        self.base = base
    }

    private override subscript(key: Base.Key) -> Base.Value? {
        get {
            return base[key]
        }
        set {
            base[key] = newValue
        }
    }

    private override var values: AnyRandomAccessCollection<Value> {
        return base.values
    }

    private override func removeAll() {
        return base.removeAll()
    }
}

fileprivate final class AnyStorageAsyncBox<Base: AsyncStorageProtocol>: AnyStorage_<Base.Key, Base.Value> {

    private var base: Base

    init(_ base: Base) {
        self.base = base
    }

    fileprivate override func asyncRead(key: Key, _ completion: (Value?) -> Void) {
        base.asyncRead(key: key, completion)
    }

    fileprivate override func asyncWrite(value: Value, to key: Key, _ completion: (() -> Void)?) {
        base.asyncWrite(value: value, to: key, completion)
    }

    fileprivate override func asyncRemove(key: Key, _ completion: ((Value?) -> Void)?) {
        base.asyncRemove(key: key, completion)
    }
}

private func notSyncStorage(file: StaticString = #file, line: UInt = #line) -> Never  {
    fatalError("Attempting to use synchronous API on asynchronous storage", file: file, line: line)
}

private func notAsyncStorage(file: StaticString = #file, line: UInt = #line) -> Never  {
    fatalError("Attempting to use asynchronous API on synchronous storage", file: file, line: line)
}


public protocol AnyStorageProtocol: SyncStorageProtocol, AsyncStorageProtocol { }


public struct AnyStorage<K: Hashable, V>: AnyStorageProtocol {

    public typealias Key = K
    public typealias Value = V

    private typealias ErasedStorage = AnyStorage_<K, V>
    private var sync: ErasedStorage? = nil
    private var async: ErasedStorage? = nil

    public init<Base: SyncStorageProtocol>(_ base: Base) where K == Base.Key, V == Base.Value {
        sync = AnyStorageSyncBox(base)
    }

    public init<Base: AsyncStorageProtocol>(_ base: Base) where K == Base.Key, V == Base.Value {
        async = AnyStorageAsyncBox(base)
    }

    public subscript(key: Key) -> Value? {
        get {
            guard let sync = sync else { notSyncStorage() }
            return sync[key]
        }
        set {
            guard let sync = sync else { notSyncStorage() }
            sync[key] = newValue
        }
    }

    public var values: AnyRandomAccessCollection<Value> {
        guard let sync = sync else { notSyncStorage() }
        return sync.values
    }

    public func removeAll() {
        guard let sync = sync else { notSyncStorage() }
        sync.removeAll()
    }

    public func asyncRead(key: Key, _ completion: (Value?) -> Void) {
        guard let async = async else { notAsyncStorage() }
        async.asyncRead(key: key, completion)
    }

    public func asyncWrite(value: Value, to key: Key, _ completion: (() -> Void)?) {
        guard let async = async else { notAsyncStorage() }
        async.asyncWrite(value: value, to: key, completion)
    }

    public func asyncRemove(key: Key, _ completion: ((Value?) -> Void)?) {
        guard let async = async else { notAsyncStorage() }
        async.asyncRemove(key: key, completion)
    }
}

// MARK: - Value Storage

public struct AnyValueStorage<K, V>: AnyStorageProtocol where K: Hashable, V: ValueCoding, V.Coder: NSCoding, V == V.Coder.Value {
    public typealias Key = K
    public typealias Value = V

    private var box: AnyStorage<K, V.Coder>

    public init<Base: SyncStorageProtocol>(_ base: Base) where K == Base.Key, V.Coder == Base.Value {
        box = AnyStorage(base)
    }

    public init<Base: AsyncStorageProtocol>(_ base: Base) where K == Base.Key, V.Coder == Base.Value {
        box = AnyStorage(base)
    }

    public subscript(key: K) -> V? {
        get {
            return box[key]?.value
        }
        set {
            box[key] = newValue?.encoded
        }
    }

    public var values: AnyRandomAccessCollection<Value> {
        return AnyRandomAccessCollection(box.values.lazy.map { $0.value })
    }

    public func removeAll() {
        box.removeAll()
    }

    public func asyncRead(key: Key, _ completion: (Value?) -> Void) {
        box.asyncRead(key: key) { completion($0?.value) }
    }

    public func asyncWrite(value: Value, to key: Key, _ completion: (() -> Void)?) {
        box.asyncWrite(value: value.encoded, to: key, completion)
    }

    public func asyncRemove(key: Key, _ completion: ((Value?) -> Void)?) {
        typealias CompletionBlock = (V.Coder?) -> Void
        let c = completion.map { (completion) -> CompletionBlock in
            return { completion( $0?.value) }
        }
        box.asyncRemove(key: key, c)
    }
}
