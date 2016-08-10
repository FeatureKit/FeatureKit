//
//  FeatureKit
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation
import ValueCoding

// MARK: - Feature

/// Protocol which a Feature Identifier must conform to
public protocol FeatureIdentifier: Hashable, CustomStringConvertible { }

extension String: FeatureIdentifier {

    public var description: String { return self }
}

/// Default implementations of CustomStringConvertible for String based enums
public extension FeatureIdentifier where Self: RawRepresentable, Self.RawValue == String {

    var description: String { return rawValue }
}

/// Protocol which a Feature must conform to
public protocol FeatureProtocol {

    associatedtype Identifier: FeatureIdentifier

    /// - returns id: the Identifier of the Feature
    var id: Identifier { get }

    /// - returns parent: an optional parent identifier of the Feature
    var parent: Identifier? { get }

    /// - returns available: returns a boolean to indicate whether the Feature is available
    var available: Bool { get }
}

public protocol MutableFeatureProtocol: FeatureProtocol {

    /// - returns editable: returns a boolean to indicate whether the Feature could be made not available
    var editable: Bool { get }

    var defaultAvailability: Bool { get }

    mutating func set(editable editable: Bool)

    mutating func set(available available: Bool)
}

/// Default implementations of FeatureProtocol
public extension MutableFeatureProtocol {

    /// - returns editable: by default Feature's are not editable
    var editable: Bool { return false }

    public var toggled: Bool {
        return defaultAvailability != available
    }
}


public struct Feature<Identifier: FeatureIdentifier where Identifier: ValueCoding, Identifier.Coder: NSCoding, Identifier == Identifier.Coder.ValueType>: MutableFeatureProtocol {

    public let id: Identifier
    public let parent: Identifier?
    public var editable: Bool
    public let defaultAvailability: Bool
    public var currentAvailability: Bool

    public var available: Bool {
        return currentAvailability
    }

    public init(id: Identifier, parent: Identifier? = nil, editable: Bool = false, defaultAvailability: Bool = true, currentAvailability: Bool = true) {
        self.id = id
        self.parent = parent
        self.editable = editable
        self.defaultAvailability = defaultAvailability
        self.currentAvailability = currentAvailability
    }

    public mutating func set(editable newEditable: Bool) {
        editable = newEditable
    }

    public mutating func set(available newAvailable: Bool) {
        currentAvailability = newAvailable
    }
}

extension Feature: ValueCoding {
    public typealias Coder = FeatureCoder<Identifier>
}

public class FeatureCoder<Identifier: FeatureIdentifier where Identifier: ValueCoding, Identifier.Coder: NSCoding, Identifier == Identifier.Coder.ValueType>: NSObject, NSCoding, CodingType {
    public let value: Feature<Identifier>

    public required init(_ v: Feature<Identifier>) { //swiftlint:disable:this variable_name
        self.value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let id = Identifier.decode(aDecoder.decodeObjectForKey("id")) else { return nil }
        value = Feature(
            id: id,
            parent: Identifier.decode(aDecoder.decodeObjectForKey("parent")),
            editable: aDecoder.decodeBoolForKey("editable"),
            defaultAvailability: aDecoder.decodeBoolForKey("defaultAvailability"),
            currentAvailability: aDecoder.decodeBoolForKey("currentAvailability")
        )
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.id.encoded, forKey: "id")
        aCoder.encodeObject(value.parent?.encoded, forKey: "parent")
        aCoder.encodeBool(value.editable, forKey: "editable")
        aCoder.encodeBool(value.defaultAvailability, forKey: "defaultAvailability")
        aCoder.encodeBool(value.currentAvailability, forKey: "currentAvailability")
    }
}

extension FeatureIdentifier where Self:RawRepresentable, Self.RawValue == String {
    public typealias Coder = RawRepresentableStringCoder<Self>
}

public class RawRepresentableStringCoder<Value where Value: RawRepresentable, Value.RawValue == String>: NSObject, NSCoding, CodingType {
    public let value: Value

    public required init(_ v: Value) { //swiftlint:disable:this variable_name
        self.value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let
            string = aDecoder.decodeObjectForKey("value") as? String,
            v = Value(rawValue: string)
            else { return nil }
        self.value = v
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.rawValue, forKey: "value")
    }
}
