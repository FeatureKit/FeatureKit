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
    func feature(id: Feature.Identifier) -> Feature?
}

public extension FeatureServiceProtocol {

    /// Returns whether or not a feature is available.
    ///
    /// - parameter id: a Feature.Identifier
    /// - returns: a boolean, the feature's availability or false if there is no feature
    func available(id: Feature.Identifier) -> Bool {
        guard let f = feature(id) else { return false }
        let parentIsAvailable = parent(id)?.available ?? true
        return parentIsAvailable && f.available
    }

    /// The parent feature of a feature with identifier
    ///
    /// - parameter id: a Feature.Identifier
    /// - returns: if the feature exists, and it has a parent, and that parent exists
    func parent(id: Feature.Identifier) -> Feature? {
        guard let f = feature(id), parentId = f.parent, parentFeature = feature(parentId) else { return nil }
        return parentFeature
    }
}

public protocol MutableFeatureServiceProtocol: FeatureServiceProtocol {

    init(_ features: [Feature.Identifier: Feature])

    mutating func set<C: CollectionType where C.Generator.Element == Feature>(features features: C) -> Self

    mutating func set(features features: [Feature.Identifier: Feature]) -> Self
}

public extension MutableFeatureServiceProtocol {

    public typealias ReceiveFeaturesBlock = ([Feature]) -> Void
}






// MARK: - Concrete type

public final class FeatureService<Feature: FeatureProtocol> {
    public typealias Storage = AnyStorage<Feature.Identifier, Feature>

    private var storage: Storage? = nil
    private var download: Download<[Feature]>? = nil
    public private(set) var features: [Feature.Identifier: Feature]

    public required init(_ features: [Feature.Identifier: Feature] = [:]) {
        self.features = features
    }
}

extension FeatureService: MutableFeatureServiceProtocol {

    public func feature(id: Feature.Identifier) -> Feature? {
        return features[id]
    }

    public func set(features features: [Feature.Identifier: Feature]) -> FeatureService {
        self.features = features
        return self
    }

    public func set<C: CollectionType where C.Generator.Element == Feature>(features features: C) -> FeatureService {
        return set(features: features.asFeaturesByIdentifier)
    }
}

// MARK: - Storage

public extension FeatureService {

    convenience init<Base where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature>(storage base: Base) {
        self.init()
        let _ = set(storage: base)
    }

    public func set<Base where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature>(storage newStorage: Base) -> Self {
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

extension FeatureService where Feature: ValueCoding, Feature.Coder: NSCoding, Feature == Feature.Coder.ValueType {

    public func set<Base where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature.Coder>(storage newStorage: Base) -> Self {
        return set(storage: AnyValueStorage(newStorage))
    }

    public func setStorageToUserDefaults(withApplicationGroupName groupName: String? = nil) -> Self {
        return set(storage: UserDefaultsStorage(group: groupName))
    }
}

// MARK: - Remote Configuration

public extension FeatureService where Feature: CreateFromJSONProtocol {

    public typealias ReceiveFeaturesBlock = ([Feature]) -> Void

    internal func load<Base where Base: Mappable, Base.Input == RemoteData, Base.Output == [Feature]>(request request: NSURLRequest, usingSession session: NSURLSession = NSURLSession.sharedSession(), usingMapper mapper: Base, completion: ReceiveFeaturesBlock? = nil) {
        download = Download(session: session, mapper: mapper)
        download?.get(request) { [weak self] result in
            if let strongSelf = self, features = try? result.dematerialize() {
                strongSelf.set(features: features)
                completion?(features)
            }
        }
    }

    func load(request request: NSURLRequest, usingSession session: NSURLSession = NSURLSession.sharedSession(), searchForKey: String = "features", completion: VoidBlock? = nil) {
        let mapper = NotOptional(BlockMapper<RemoteData, NSData?> { $0.0 }).append(Feature.mapper(searchForKey: searchForKey))
        return load(request: request, usingSession: session, usingMapper: mapper) { _ in completion?() }
    }

    func load(URL: NSURL, usingSession session: NSURLSession = NSURLSession.sharedSession(), searchForKey: String = "features", completion: VoidBlock? = nil) {
        load(request: NSURLRequest(URL: URL), usingSession: session, searchForKey: searchForKey, completion: completion)
    }
}
