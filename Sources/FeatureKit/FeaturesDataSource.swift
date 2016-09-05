//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

public protocol FeaturesDataSourceProtocol {

    associatedtype Feature: FeatureProtocol

    var numberOfGroups: Int { get }

    func numberOfFeaturesInGroupAtIndex(index: Int) -> Int

    func featureAtIndex(_: Int, inGroup: Int) -> Feature
}

public class FeaturesDataSource<Service: FeatureServiceProtocol> {
    public typealias Feature = Service.Feature

    private var service: Service

    public init(service: Service) {
        self.service = service
    }

}


internal extension FeatureServiceProtocol {

    var groups: Dictionary<Feature.Identifier,Feature> {
        return features.values.filter({ $0.parent == nil }).asFeaturesByIdentifier
    }

    func group(atIndex index: Int) -> [Feature] {
        let _groups = groups
        let parent = (Array<Feature.Identifier>)(_groups.keys)[index]
        guard let feature = _groups[parent] else { return [] }
        var result = [feature]
        result.appendContentsOf(features(withParentIdentifier: parent))
        return result
    }

    func features(withParentIdentifier parent: Feature.Identifier) -> [Feature] {
        return features.values.filter { $0.parent == parent }
    }
}

extension FeaturesDataSource: FeaturesDataSourceProtocol {

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