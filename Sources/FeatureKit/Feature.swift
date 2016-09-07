//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import ValueCoding

// MARK: - Support Interfaces

/// Public protocol to support creating types from a string
public protocol StringRepresentable: CustomStringConvertible {

    /// Will support creating the type from a string
    init?(string: String)
}

extension RawRepresentable where RawValue == String {

    /// - returns: a string representation of self
    public var description: String { return rawValue }

    /// Creates the type uing the input as the raw value
    /// this makes it possible for String backed enums to automatically conform
    /// to StringRepresentable - allowing them to be created automatically
    /// from JSON fragments.
    public init?(string: String) {
        self.init(rawValue: string)
    }
}

// MARK: - FeatureIdentifier

/// Protocol which a Feature Identifier must conform to
public protocol FeatureIdentifier: Hashable, StringRepresentable { }

public func < <ID: FeatureIdentifier where ID: RawRepresentable, ID.RawValue == String> (lhs: ID, rhs: ID) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

extension String: FeatureIdentifier {

    /// - returns: a string representation of self
    public var description: String { return self }

    /// Just initalizes self from another string to ensure conformance
    public init?(string: String) {
        self = string
    }
}

// MARK: - FeatureProtocol

/// Protocol which a Feature must conform to
public protocol FeatureProtocol {

    associatedtype Identifier: FeatureIdentifier

    /// - returns id: the Identifier of the Feature
    var id: Identifier { get }

    /// - returns parent: an optional parent identifier of the Feature
    var parent: Identifier? { get }

    /// - returns title: a human readable title for this feature
    var title: String { get }

    /// - returns available: returns a boolean to indicate whether the Feature is available
    var isAvailable: Bool { get }
}

// MARK: - MutableFeatureProtocol

public protocol MutableFeatureProtocol: FeatureProtocol {

    /// - returns editable: returns a boolean to indicate whether the Feature could be made not available
    var isEditable: Bool { get }

    /// - returns defaultAvailability: The default availability of the feature
    var defaultAvailability: Bool { get }

    /// Sets the editable property
    /// - parameter editable: the new Bool value of editable
    mutating func set(editable editable: Bool)

    /// Sets the available property
    /// - parameter available: the new Bool value of available
    mutating func set(available available: Bool)
}

/// Default implementations of FeatureProtocol
public extension MutableFeatureProtocol {

    /// - returns editable: by default Feature's are not editable
    var isEditable: Bool { return false }

    public var isToggled: Bool {
        return defaultAvailability != isAvailable
    }
}

public func < <Feature: FeatureProtocol where Feature.Identifier: Comparable>(lhs: Feature, rhs: Feature) -> Bool {
    switch (lhs.parent, rhs.parent) {
    case (.None, .Some(_)): return true
    case (.Some(_), .None): return false
    default: return lhs.id < rhs.id
    }
}

extension CollectionType where Generator.Element: FeatureProtocol {

    public var asFeaturesByIdentifier: [Generator.Element.Identifier: Generator.Element] {
        return reduce([:]) { var acc = $0; acc[$1.id] = $1; return acc }
    }
}

// MARK: - Feature<Identifier>

public struct Feature<ID: FeatureIdentifier where ID: ValueCoding, ID.Coder: NSCoding, ID == ID.Coder.ValueType>: MutableFeatureProtocol {

    public typealias Identifier = ID

    public let id: ID
    public let parent: ID?
    public let title: String
    public var isEditable: Bool
    public let defaultAvailability: Bool
    public var currentAvailability: Bool

    public var isAvailable: Bool {
        return currentAvailability
    }

    public init(id: ID, parent: ID? = nil, title: String, editable: Bool = false, defaultAvailability: Bool = true, currentAvailability: Bool = true) {
        self.id = id
        self.parent = parent
        self.title = title
        self.isEditable = editable
        self.defaultAvailability = defaultAvailability
        self.currentAvailability = currentAvailability
    }

    public mutating func set(editable newEditable: Bool) {
        isEditable = newEditable
    }

    public mutating func set(available newAvailable: Bool) {
        currentAvailability = newAvailable
    }
}



// MARK: - ValueCoding

extension Feature: ValueCoding {
    public typealias Coder = FeatureCoder<Identifier>
}

public class FeatureCoder<Identifier: FeatureIdentifier where Identifier: ValueCoding, Identifier.Coder: NSCoding, Identifier == Identifier.Coder.ValueType>: NSObject, NSCoding, CodingType {
    public let value: Feature<Identifier>

    public required init(_ v: Feature<Identifier>) { //swiftlint:disable:this variable_name
        self.value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let
            id = Identifier.decode(aDecoder.decodeObjectForKey("id")),
            title = aDecoder.decodeObjectForKey("title") as? String
        else { return nil }
        value = Feature(
            id: id,
            parent: Identifier.decode(aDecoder.decodeObjectForKey("parent")),
            title: title,
            editable: aDecoder.decodeBoolForKey("editable"),
            defaultAvailability: aDecoder.decodeBoolForKey("defaultAvailability"),
            currentAvailability: aDecoder.decodeBoolForKey("currentAvailability")
        )
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.id.encoded, forKey: "id")
        aCoder.encodeObject(value.parent?.encoded, forKey: "parent")
        aCoder.encodeObject(value.title, forKey: "title")
        aCoder.encodeBool(value.isEditable, forKey: "editable")
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
