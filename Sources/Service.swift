//
//  Service.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import Foundation
import ValueCoding

// MARK: - Service

public class Service<Feature: FeatureProtocol> {

    // swiftlint:disable variable_name
    private var _features: [Feature.Identifier: Feature]
    private var _storage: AnyStorage<Feature>? = .None
    // swiftlint:enable variable_name

    public var features: [Feature] {
        return Array(_features.values)
    }

    public init(_ features: [Feature.Identifier: Feature] = [:]) {
        _features = features
    }

    public convenience init(_ features: [Feature]) {
        self.init()
        setFeatures(features)
    }

    internal func setFeatures(features: [Feature]) {
        _features = features.reduce([:]) { var acc = $0; acc[$1.id] = $1; return acc }
    }
}

extension Service: ServiceProtocol {

    public func feature(id: Feature.Identifier) -> Feature? {
        return _features[id]
    }
}

// MARK: - Storage

public extension Service {

    convenience init<Storage where Storage: StorageAdaptor, Feature == Storage.Item>(storage: Storage, completion: VoidBlock? = nil) {
        self.init()
        let _ = setStorage(storage)
    }

    func removeStorage(completion: VoidBlock? = nil) {
        if let storage = _storage {
            storage.removeAll(completion)
        }
        else {
            completion?()
        }
    }

    func setStorage<Storage where Storage: StorageAdaptor, Feature == Storage.Item>(storage: Storage, completion: VoidBlock? = nil) -> Self {
        removeStorage { [unowned self] in
            self._storage = AnyStorage(storage)
            self._storage?.read { items in
                self.setFeatures(items)
                completion?()
            }
        }
        return self
    }
}

extension Service where Feature: NSCoding {

    public func setStorageToUserDefaults(completion: VoidBlock? = nil) -> Self {
        return setStorage(UserDefaultsAdaptor<Feature>(), completion: completion)
    }
}

extension Service where Feature: ValueCoding, Feature.Coder: NSCoding, Feature == Feature.Coder.ValueType {

    public func setStorageToUserDefaults(completion: VoidBlock? = nil) -> Self {
        return setStorage(AnyValueStorage(UserDefaultsAdaptor<Feature.Coder>()), completion: completion)
    }
}
