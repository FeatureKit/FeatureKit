//
//  Service.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import Foundation

// MARK: - Implementation

public enum FeatureServiceError<Feature: FeatureType>: ErrorType {
    case FeatureNotDefined(Feature.Identifier)
}

public class FeatureService<Feature: FeatureType>: FeatureServiceType {

    internal var features: [Feature.Identifier: Feature]

    public init(features: [Feature.Identifier: Feature]) {
        self.features = features
    }

    public convenience init(_ f: [Feature]) {
        self.init(features: f.reduce([:]) { var acc = $0; acc[$1.identifier] = $1; return acc })
    }

    public func feature(identifier: Feature.Identifier) throws -> Feature {
        guard let f = features[identifier] else {
            throw FeatureServiceError<Feature>.FeatureNotDefined(identifier)
        }
        return f
    }
}
