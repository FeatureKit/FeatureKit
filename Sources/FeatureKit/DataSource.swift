//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

public protocol DataSourceProtocol {

    associatedtype Feature: FeatureProtocol

    var numberOfGroups: Int { get }

    func numberOfFeaturesInGroupAtIndex(index: Int) -> Int

    func featureAtIndex(_: Int, inGroup: Int) -> Feature
}

public class DataSource<Service: FeatureServiceProtocol where Service.Feature.Identifier: Comparable> {
    public typealias Feature = Service.Feature

    private var service: Service

    public init(service: Service) {
        self.service = service
    }

}

internal extension FeatureServiceProtocol where Feature.Identifier: Comparable {

    var groups: Dictionary<Feature.Identifier,Feature> {
        return features.values.filter({ $0.parent == nil }).asFeaturesByIdentifier
    }

    var groupIdentifiers: [Feature.Identifier] {
        return groups.keys.sort()
    }

    func group(atIndex index: Int) -> [Feature] {
        return features(associatedWithIdentifier: groupIdentifiers[index])
    }

    func features(associatedWithIdentifier searchId: Feature.Identifier) -> [Feature] {
        return features.values.filter({ $0.parent == searchId || $0.id == searchId }).sort(<)
    }
}

extension DataSource: DataSourceProtocol {

    public var numberOfGroups: Int {
        return service.groups.count
    }

    public func numberOfFeaturesInGroupAtIndex(index: Int) -> Int {
        return service.group(atIndex: index).count
    }

    public func featureAtIndex(index: Int, inGroup groupIndex: Int) -> Feature {
        return service.group(atIndex: groupIndex)[index]
    }
}

