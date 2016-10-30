//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation
import ValueCoding

// MARK: - Service

/// Protocol which defines the interface for a Service
public protocol FeatureServiceProtocol {

    /// The type of the Feature that the Service provides
    associatedtype Feature: FeatureProtocol

    /// Access all features
    ///
    /// - returns: a Dictionary of Features keyed by their id
    var features: Dictionary<Feature.Identifier, Feature> { get }

    /// Access a feature by its identifier
    ///
    /// - parameter id: a Feature.Identifier
    /// - returns: a Feature if owned by the service, nil if not.
    func feature(withIdentifier id: Feature.Identifier) -> Feature?
}

public extension FeatureServiceProtocol {

    /// Returns whether or not a feature is available.
    ///
    /// - parameter id: a Feature.Identifier
    /// - returns: a boolean, the feature's availability or false if there is no feature
    func isAvailable(withIdentifier id: Feature.Identifier) -> Bool {
        guard let f = feature(withIdentifier: id) else { return false }
        let parentIsAvailable = f.parent.flatMap { feature(withIdentifier: $0)?.isAvailable } ?? true
        return parentIsAvailable && f.isAvailable
    }

    /// The parent feature of a feature with identifier
    ///
    /// - parameter id: a Feature.Identifier
    /// - returns: if the feature exists, and it has a parent, and that parent exists
    func parent(ofFeatureWithIdentifier id: Feature.Identifier) -> Feature? {
        return feature(withIdentifier: id)?.parent.flatMap(feature(withIdentifier:))
    }
}

public protocol MutableFeatureServiceProtocol: FeatureServiceProtocol {

    init(_ features: [Feature.Identifier: Feature])

    @discardableResult mutating func set<C: Collection>(features: C) -> Self where C.Iterator.Element == Feature

    @discardableResult mutating func set(features: [Feature.Identifier: Feature]) -> Self
}

public extension MutableFeatureServiceProtocol {

    public typealias ReceiveFeaturesBlock = ([Feature]) -> Void
}






// MARK: - Concrete type

public final class FeatureService<Feature: FeatureProtocol> {
    public typealias Storage = AnyStorage<Feature.Identifier, Feature>

    fileprivate var storage: Storage? = nil
    public fileprivate(set) var features: [Feature.Identifier: Feature]

    public required init(_ features: [Feature.Identifier: Feature] = [:]) {
        self.features = features
    }
}

extension FeatureService: MutableFeatureServiceProtocol {

    public func feature(withIdentifier id: Feature.Identifier) -> Feature? {
        return features[id]
    }

    @discardableResult public func set(features: [Feature.Identifier: Feature]) -> FeatureService {
        self.features = features
        return self
    }

    @discardableResult public func set<C: Collection>(features: C) -> FeatureService where C.Iterator.Element == Feature {
        return set(features: features.asFeaturesByIdentifier)
    }
}

// MARK: - Storage

public extension FeatureService {

    convenience init<Base>(storage base: Base) where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature {
        self.init()
        let _ = set(storage: base)
    }

    public func set<Base>(storage newStorage: Base) -> Self where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature {
        set(features: newStorage.values)
        storage?.removeAll()
        storage = AnyStorage(newStorage)
        return self
    }
}

public extension FeatureService where Feature: NSCoding {

    func setStorageToUserDefaults(withApplicationGroupName groupName: String? = nil) -> Self {
        return set(storage: UserDefaultsStorage(group: groupName))
    }
}

extension FeatureService where Feature: ValueCoding, Feature.Coder: NSCoding, Feature == Feature.Coder.Value {

    public func set<Base>(storage newStorage: Base) -> Self where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature.Coder {
        return set(storage: AnyValueStorage(newStorage))
    }

    public func setStorageToUserDefaults(withApplicationGroupName groupName: String? = nil) -> Self {
        return set(storage: UserDefaultsStorage(group: groupName))
    }
}

