//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Marshal

internal enum FeatureKey: String, KeyType {
    case id = "id"
    case parent = "parent"
    case title = "title"
    case editable = "editable"
    case available = "available"
    case defaultAvailability = "defaultAvailable"

    var stringValue: String {
        return rawValue
    }
}

extension Feature: Unmarshaling {
    typealias Key = FeatureKey

    public init(object: MarshaledObject) throws {
        guard let id = ID(string: try object.value(for: Key.id)) else { throw MarshalError.nullValue(key: Key.id) }
        let parentId: String? = try? object.value(for: Key.parent)
        let editable: Bool? = try? object.value(for: Key.editable)
        let available: Bool = try object.value(for: Key.available)

        self.id = id
        self.parent = parentId.flatMap { ID(string: $0) }
        self.title = try object.value(for: Key.title)
        self.isEditable = editable ?? false
        self.currentAvailability = available
        self.defaultAvailability = try object.value(for: Key.defaultAvailability) ?? available
    }
}
