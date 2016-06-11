//
//  Features.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import Foundation

public protocol FeatureIdentifierType: Hashable, CustomStringConvertible { }

public protocol FeatureType {
    associatedtype Identifier: FeatureIdentifierType

    var identifier: Identifier { get }

    var parent: Identifier? { get }

    var editable: Bool { get }

    var available: Bool { get }
}

public extension FeatureType {

    var editable: Bool { return false }
}

public protocol FeatureServiceType {
    associatedtype Feature: FeatureType

    func feature(identifier: Feature.Identifier) throws -> Feature

    func available(identifier: Feature.Identifier) -> Bool
}

public extension FeatureServiceType {

    func parent(identifier: Feature.Identifier) -> Feature? {
        guard let
            f: Feature = try? feature(identifier),
            p = f.parent,
            feature = try? feature(p) else { return .None }
        return feature
    }

    func available(identifier: Feature.Identifier) -> Bool {
        guard let feature = try? feature(identifier) else { return false }
        let p = parent(identifier)?.available ?? true
        return p && feature.available
    }
}