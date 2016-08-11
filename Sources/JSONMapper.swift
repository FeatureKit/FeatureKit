//
//  JSONMapper.swift
//  Features
//
//  Created by Daniel Thorpe on 11/08/2016.
//
//

import Foundation

public enum JSONError: ErrorType {
    case keyNotFound(String)
}

public struct DataJSONMapper: Mappable {

    public func map(input: NSData) throws -> AnyObject {
        return try NSJSONSerialization.JSONObjectWithData(input, options: [])
    }
}

public struct JSONExtractFragment: Mappable {

    enum Search {
        case key(String)
        // TODO: support searching a key path here
    }

    let search: Search

    public init(forKey key: String) {
        search = .key(key)
    }

    public func map(input: [String: AnyObject]) throws -> AnyObject {
        switch search {
        case .key(let key):
            guard let result = input[key] else { throw JSONError.keyNotFound(key) }
            return result
        }
    }
}
