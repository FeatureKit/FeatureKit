//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation

public struct JSON {

    public typealias Hash = Dictionary<String, AnyObject>
    public typealias List = Array<Hash>

    public enum Error: ErrorType {
        case unableToCreateFromJSON(Hash)
        case keyNotFound(String)
        case unableToSearchArrays
    }

    enum SearchTerm {
        case key(String)
    }

    public struct DataMapper: Mappable {

        public func map(input: NSData) throws -> AnyObject {
            return try NSJSONSerialization.JSONObjectWithData(input, options: [])
        }
    }

    public struct Search: Mappable {

        let search: SearchTerm

        public init(forKey key: String) {
            search = .key(key)
        }

        public init<Key: RawRepresentable where Key.RawValue == String>(forKey key: Key) {
            search = .key(key.rawValue)
        }

        public func map(input: Hash) throws -> AnyObject {
            switch search {
            case let .key(key):
                guard let result = input[key] else { throw Error.keyNotFound(key) }
                return result
            }
        }
    }

    public struct Coercion {
        // object coercions
        static let string = AnyObjectCoercion<String>()
        static let data = AnyObjectCoercion<NSData>()
        static let number = AnyObjectCoercion<NSNumber>()

        // primitives coercions
        static let bool = AnyMapper(number).append { $0.boolValue }
        static let int = AnyMapper(number).append { $0.intValue }

        // flat mapped
        static let flatMapString = FlatMap(JSON.Coercion.string)
        static let flatMapBool = FlatMap(JSON.Coercion.bool)

        static let toHash = AnyObjectCoercion<JSON.Hash>()
        static let toList = AnyObjectCoercion<JSON.List>()
    }
}

// MARK: - JSON Creation

public protocol CreateFromJSONProtocol {

    static func mapper(searchForKey key: String?) -> AnyMapper<NSData, [Self]>

    static func create(from json: JSON.Hash) throws -> Self
}

internal struct JSONFeature {

    enum Key: String {
        case id = "id"
        case parent = "parent"
        case title = "title"
        case editable = "editable"
        case defaultAvailability = "defaultAvailability"
        case currentAvailability = "currentAvailability"
    }

    struct Find {

        // Note that these are lazily created function, which receive a JSON.Fragment, which they search
        // for the correct key, and return the appropriate type or nil, or throw an error.

        static let identifier = JSON.Search(forKey: Key.id).append(JSON.Coercion.string).map
        static let title = JSON.Search(forKey: Key.title).append(JSON.Coercion.string).map
        static let parent = CatchAsOptional(JSON.Search(forKey: Key.parent)).append(JSON.Coercion.flatMapString).map
        static let editable = CatchAsOptional(JSON.Search(forKey: Key.editable)).append(JSON.Coercion.flatMapBool).map
        static let defaultAvailability = JSON.Search(forKey: Key.defaultAvailability).append(JSON.Coercion.bool).map
        static let currentAvailability = CatchAsOptional(JSON.Search(forKey: Key.currentAvailability)).append(JSON.Coercion.flatMapBool).map
    }
}

internal struct JSONFeatureMapper<F: CreateFromJSONProtocol>: Mappable {

    internal func map(input: JSON.Hash) throws -> F {
        return try F.create(from: input)
    }
}

extension Feature: CreateFromJSONProtocol {

    public static func mapper(searchForKey key: String? = nil) -> AnyMapper<NSData, [Feature]> {
        let data = JSON.DataMapper()
        let features = Many(JSONFeatureMapper<Feature>())
        if let key = key {
            return data
                .append(JSON.Coercion.toHash)
                .append(JSON.Search(forKey: key))
                .append(JSON.Coercion.toList)
                .append(features)
        }
        else {
            return data
                .append(JSON.Coercion.toList)
                .append(features)
        }
    }

    public static func create(from json: JSON.Hash) throws -> Feature {
        do {
            let idString = try JSONFeature.Find.identifier(json)
            let parentString = try JSONFeature.Find.parent(json)
            let title = try JSONFeature.Find.title(json)
            let editable = try JSONFeature.Find.editable(json)
            let defaultAvailable = try JSONFeature.Find.defaultAvailability(json)
            let currentAvailable = try JSONFeature.Find.currentAvailability(json)

            guard let id = Feature.Identifier(string: idString) else { throw JSON.Error.unableToCreateFromJSON(json) }

            return Feature(
                id: id,
                parent: parentString.flatMap { Feature.Identifier(string: $0) },
                title: title,
                editable: editable ?? false,
                defaultAvailability: defaultAvailable,
                currentAvailability: currentAvailable ?? defaultAvailable
            )
        }
    }
}
