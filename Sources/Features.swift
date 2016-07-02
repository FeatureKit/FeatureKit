//
//  Features.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import Foundation

// MARK: - Feature

/// Protocol which a Feature Identifier must conform to
public protocol FeatureIdentifier: Hashable, CustomStringConvertible { }

/// Default implementations of CustomStringConvertible for String based enums
public extension FeatureIdentifier where Self: RawRepresentable, Self.RawValue == String {

    var description: String { return rawValue }
}

/// Protocol which a Feature Identifier must conform to
public protocol FeatureProtocol {

    associatedtype Identifier: FeatureIdentifier

    /// - returns id: the Identifier of the Feature
    var id: Identifier { get }

    /// - returns parent: an optional parent identifier of the Feature
    var parent: Identifier? { get }

    /// - returns editable: returns a boolean to indicate whether the Feature could be made not available
    var editable: Bool { get }

    /// - returns available: returns a boolean to indicate whether the Feature is available
    var available: Bool { get }
}

/// Default implementations of FeatureProtocol
public extension FeatureProtocol {

    /// - returns editable: by default Feature's are not editable
    var editable: Bool { return false }
}

// MARK: - Service

/// Protocol which defines the interface for a Feature Service
public protocol ServiceProtocol {

    /// The type of the Feature that the Service provides
    associatedtype Feature: FeatureProtocol

    /// Access a feature by its identifier
    ///
    /// - parameter id: a Feature.Identifier
    /// - returns: a Feature if owned by the service, nil if not.
    func feature(id: Feature.Identifier) -> Feature?
}

public extension ServiceProtocol {

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
        guard let f = feature(id), parentId = f.parent, parentFeature = feature(parentId) else { return .None }
        return parentFeature
    }

}
