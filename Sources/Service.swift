//
//  FeatureKit
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation
import ValueCoding

// MARK: - Service

/// Protocol which defines the interface for a Service
public protocol FeatureServiceProtocol {

    /// The type of the Feature that the Service provides
    associatedtype Feature: FeatureProtocol

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


// MARK: - Concrete type

public class FeatureService<Feature: FeatureProtocol> {
    public typealias Storage = AnyStorage<Feature.Identifier, Feature>
    public typealias Mapper = AnyMapper<RemoteResult, [Feature]>

    private var _features: [Feature.Identifier: Feature] // swiftlint:disable:this variable_name
    private var storage: Storage? = nil
    private var mapper: Mapper? = nil
    private var download: Download? = nil

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

    internal func setFeatures<C: CollectionType where C.Generator.Element == Feature>(features: C) {
        _features = features.reduce([:]) { var acc = $0; acc[$1.id] = $1; return acc }
    }
}

extension FeatureService: FeatureServiceProtocol {

    public func feature(id: Feature.Identifier) -> Feature? {
        return _features[id]
    }
}

// MARK: - Storage

public extension FeatureService {

    convenience init<Base where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature>(storage base: Base) {
        self.init()
        let _ = set(storage: base)
    }

    public func set<Base where Base: SyncStorageProtocol, Base.Key == Feature.Identifier, Base.Value == Feature>(storage newStorage: Base) -> Self {
        setFeatures(newStorage.values)
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

public extension FeatureService {

    public typealias ReceiveFeaturesBlock = ([Feature]) -> Void

    public func set<Base where Base: Mappable, Base.Input == RemoteResult, Base.Output == [Feature]>(mapper newMapper: Base) -> Self {
        mapper = AnyMapper(newMapper)
        return self
    }

    public func load<Base where Base: Mappable, Base.Input == RemoteResult, Base.Output == [Feature]>(URL: NSURL, usingSession session: NSURLSession = NSURLSession.sharedSession(), usingMapper oneTimeMapper: Base? = nil, completion: ReceiveFeaturesBlock? = nil) {
        load(request: NSURLRequest(URL: URL), usingSession: session, usingMapper: oneTimeMapper, completion: completion)
    }

    public func load<Base where Base: Mappable, Base.Input == RemoteResult, Base.Output == [Feature]>(request request: NSURLRequest, usingSession session: NSURLSession = NSURLSession.sharedSession(), usingMapper oneTimeMapper: Base? = nil, completion: ReceiveFeaturesBlock? = nil) {
        guard let mapper = oneTimeMapper.map({ AnyMapper($0) }) ?? self.mapper else { return }
        download = Download(session: session)
        download?.get(request, mapAndSetFeatures(mapper, onCompletion: completion))
    }

    internal func mapAndSetFeatures(mapper: AnyMapper<RemoteResult, [Feature]>, onCompletion completion: ReceiveFeaturesBlock? = nil) -> (RemoteResult) -> Void {
        let _setFeatures: ReceiveFeaturesBlock = setFeatures
        return { result in
            let features = mapper.map(result)
            _setFeatures(features)
            completion?(features)
        }
    }
}
