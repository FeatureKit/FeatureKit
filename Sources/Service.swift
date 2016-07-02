//
//  Service.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import Foundation

// MARK: - AbstractService

public class AbstractService<Feature: FeatureProtocol> {

    internal var features: [Feature.Identifier: Feature]

    public init(features: [Feature.Identifier: Feature]) {
        self.features = features
    }

    public convenience init(_ features: [Feature]) {
        self.init(features: features.reduce([:]) { var acc = $0; acc[$1.id] = $1; return acc })
    }
}

extension AbstractService: FeatureServiceProtocol {

    public func feature(id: Feature.Identifier) -> Feature? {
        return features[id]
    }
}
