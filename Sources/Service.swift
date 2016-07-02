//
//  Service.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import Foundation

// MARK: - AbstractService

public class Service<Feature: FeatureProtocol> {

    internal var storage: [Feature.Identifier: Feature]

    public var features: [Feature] {
        return Array(storage.values)
    }

    public init(features: [Feature.Identifier: Feature]) {
        storage = features
    }

    public convenience init(_ features: [Feature]) {
        self.init(features: features.reduce([:]) { var acc = $0; acc[$1.id] = $1; return acc })
    }
}

extension Service: ServiceProtocol {

    public func feature(id: Feature.Identifier) -> Feature? {
        return storage[id]
    }
}
