//
//  FeatureKit
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation
import ValueCoding

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

    func asyncRead(key key: Key, _: (Value?) -> Void)

    func asyncWrite(value value: Value, to: Key, _: (() -> Void)?)

    func asyncRemove(key key: Key, _: ((Value?) -> Void)?)
}

@noreturn private func _abstractMethod(file: StaticString = #file, line: UInt = #line) {
    fatalError("Method must be overriden", file: file, line: line)
}

private class AnyStorage_<K: Hashable, V>: SyncStorageProtocol, AsyncStorageProtocol {
    typealias Key = K
    typealias Value = V

    private subscript(key: Key) -> Value? {
        get {
            _abstractMethod()
        }
        set {
            _abstractMethod()
        }
    }

    private var values: AnyRandomAccessCollection<Value> {
        _abstractMethod()
    }

    private func removeAll() {
        _abstractMethod()
    }

    private func asyncRead(key key: Key, _: (Value?) -> Void) {
        _abstractMethod()
    }

    private func asyncWrite(value value: Value, to: Key, _: (() -> Void)?) {
        _abstractMethod()
    }

    private func asyncRemove(key key: Key, _: ((Value?) -> Void)?) {
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

private final class AnyStorageAsyncBox<Base: AsyncStorageProtocol>: AnyStorage_<Base.Key, Base.Value> {

    private var base: Base

    init(_ base: Base) {
        self.base = base
    }

    private override func asyncRead(key key: Key, _ completion: (Value?) -> Void) {
        base.asyncRead(key: key, completion)
    }

    private override func asyncWrite(value value: Value, to key: Key, _ completion: (() -> Void)?) {
        base.asyncWrite(value: value, to: key, completion)
    }

    private override func asyncRemove(key key: Key, _ completion: ((Value?) -> Void)?) {
        base.asyncRemove(key: key, completion)
    }
}

@noreturn private func notSyncStorage(file: StaticString = #file, line: UInt = #line) {
    fatalError("Attempting to use synchronous API on asynchronous storage", file: file, line: line)
}

@noreturn private func notAsyncStorage(file: StaticString = #file, line: UInt = #line) {
    fatalError("Attempting to use asynchronous API on synchronous storage", file: file, line: line)
}


public protocol AnyStorageProtocol: SyncStorageProtocol, AsyncStorageProtocol { }


public struct AnyStorage<K: Hashable, V>: AnyStorageProtocol {

    public typealias Key = K
    public typealias Value = V

    private typealias ErasedStorage = AnyStorage_<K, V>
    private var sync: ErasedStorage? = nil
    private var async: ErasedStorage? = nil

    public init<Base: SyncStorageProtocol where K == Base.Key, V == Base.Value>(_ base: Base) {
        sync = AnyStorageSyncBox(base)
    }

    public init<Base: AsyncStorageProtocol where K == Base.Key, V == Base.Value>(_ base: Base) {
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

    public func asyncRead(key key: Key, _ completion: (Value?) -> Void) {
        guard let async = async else { notAsyncStorage() }
        async.asyncRead(key: key, completion)
    }

    public func asyncWrite(value value: Value, to key: Key, _ completion: (() -> Void)?) {
        guard let async = async else { notAsyncStorage() }
        async.asyncWrite(value: value, to: key, completion)
    }

    public func asyncRemove(key key: Key, _ completion: ((Value?) -> Void)?) {
        guard let async = async else { notAsyncStorage() }
        async.asyncRemove(key: key, completion)
    }
}

// MARK: - Value Storage

public struct AnyValueStorage<K, V where K: Hashable, V: ValueCoding, V.Coder: NSCoding, V == V.Coder.ValueType>: AnyStorageProtocol {
    public typealias Key = K
    public typealias Value = V

    private var box: AnyStorage<K, V.Coder>

    public init<Base: SyncStorageProtocol where K == Base.Key, V.Coder == Base.Value>(_ base: Base) {
        box = AnyStorage(base)
    }

    public init<Base: AsyncStorageProtocol where K == Base.Key, V.Coder == Base.Value>(_ base: Base) {
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

    public func asyncRead(key key: Key, _ completion: (Value?) -> Void) {
        box.asyncRead(key: key) { completion($0?.value) }
    }

    public func asyncWrite(value value: Value, to key: Key, _ completion: (() -> Void)?) {
        box.asyncWrite(value: value.encoded, to: key, completion)
    }

    public func asyncRemove(key key: Key, _ completion: ((Value?) -> Void)?) {
        typealias CompletionBlock = (V.Coder?) -> Void
        let c = completion.map { (completion) -> CompletionBlock in
            return { completion( $0?.value) }
        }
        box.asyncRemove(key: key, c)
    }
}
