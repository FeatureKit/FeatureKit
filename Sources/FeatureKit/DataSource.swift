//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

public enum DataSourceStyle {
    case basic, grouped
}

public protocol DataSourceProtocol {

    associatedtype Feature: MutableFeatureProtocol

    var style: DataSourceStyle { get }

    var numberOfSections: Int { get }

    func numberOfFeatures(inSection sectionIndex: Int) -> Int

    func feature(atIndex index: Int, inSection: Int) -> Feature
}

public class DataSource<Service: FeatureServiceProtocol where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable> {
    public typealias Feature = Service.Feature

    public private(set) var service: Service
    public private(set) var style: DataSourceStyle

    public init(service: Service) {
        self.service = service
        self.style = service.style
    }
}

internal extension FeatureServiceProtocol where Feature.Identifier: Comparable {

    var count: Int {
        return features.count
    }

    var topLevelFeatures: Dictionary<Feature.Identifier,Feature> {
        return features.values.filter({ $0.parent == nil }).asFeaturesByIdentifier
    }

    var topLevelFeatureIdentifiers: [Feature.Identifier] {
        return topLevelFeatures.keys.sort()
    }

    var style: DataSourceStyle {
        return topLevelFeatures.count == count ? .basic : .grouped
    }

    func numberOfSections(withStyle style: DataSourceStyle) -> Int {
        switch style {
        case .basic: return 1
        case .grouped: return topLevelFeatures.count
        }
    }

    func numberOfFeatures(inSection sectionIndex: Int, withStyle style: DataSourceStyle) -> Int {
        switch style {
        case .basic: return features.count
        case .grouped: return features(inSection: sectionIndex, withStyle: .grouped).count
        }
    }

    func features(inSection index: Int, withStyle style: DataSourceStyle) -> [Feature] {
        switch style {
        case .basic: return features.values.sort(<)
        case .grouped: return features(associatedWithIdentifier: topLevelFeatureIdentifiers[index])
        }
    }

    func features(associatedWithIdentifier searchId: Feature.Identifier) -> [Feature] {
        return features.values.filter({ $0.parent == searchId || $0.id == searchId }).sort(<)
    }
}

extension DataSource: DataSourceProtocol {

    public var numberOfSections: Int {
        return service.numberOfSections(withStyle: style)
    }

    public func numberOfFeatures(inSection sectionIndex: Int) -> Int {
        return service.numberOfFeatures(inSection: sectionIndex, withStyle: style)
    }

    public func feature(atIndex index: Int, inSection sectionIndex: Int) -> Feature {
        return service.features(inSection: sectionIndex, withStyle: style)[index]
    }
}

