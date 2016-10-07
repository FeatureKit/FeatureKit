//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
@testable import FeatureKit

class TestableUserDefaults: UserDefaultsProtocol {

    var objects: [String: Any] = [:]

    var didReadObjectForKey: String? = .none
    var didSetObjectForKey: String? = .none
    var didRemoveObjectForKey: String? = .none
    var didGetDictionaryRepresentation = false

    func object(forKey defaultName: String) -> Any? {
        didReadObjectForKey = defaultName
        return objects[defaultName]
    }

    func set(_ value: Any?, forKey defaultName: String) {
        didSetObjectForKey = defaultName
        objects[defaultName] = value
    }

    func removeObject(forKey defaultName: String) {
        didRemoveObjectForKey = defaultName
        objects.removeValue(forKey: defaultName)
    }

    func dictionaryRepresentation() -> [String: Any] {
        didGetDictionaryRepresentation = true
        return objects
    }
}

class ArchivableTestFeature: NSObject, NSCoding, FeatureProtocol {

    typealias FeatureIdentifier = String

    let id: String
    var parent: String? = .none
    var title: String
    var isEditable: Bool = false
    var isAvailable: Bool = false

    init(id: String, parent: String? = .none, title: String, available: Bool = false) {
        self.id = id
        self.parent = parent
        self.title = title
        self.isAvailable = available
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        guard let
            identifier = aDecoder.decodeObject(forKey: "id") as? String
        else { return nil }

        id = identifier
        parent = aDecoder.decodeObject(forKey: "parent") as? String
        title = aDecoder.decodeObject(forKey: "title") as! String
        isEditable = aDecoder.decodeBool(forKey: "editable")
        isAvailable = aDecoder.decodeBool(forKey: "available")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(isAvailable, forKey: "available")
        aCoder.encode(isEditable, forKey: "editable")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(parent, forKey: "parent")
        aCoder.encode(id, forKey: "id")
    }
}

class UserDefaultsStorageTests: XCTestCase {

    typealias UserDefaultsAdaptor = UserDefaultsStorage<String, ArchivableTestFeature>
    typealias Storage = AnyStorage<String, ArchivableTestFeature>

    var testableUserDefaults: TestableUserDefaults!
    var adaptor: UserDefaultsAdaptor!
    var storage: Storage!

    override func setUp() {
        super.setUp()
        testableUserDefaults = TestableUserDefaults()
        adaptor = UserDefaultsStorage()
        adaptor.userDefaults = testableUserDefaults as UserDefaultsProtocol
        storage = AnyStorage(adaptor)
    }

    override func tearDown() {
        storage = nil
        adaptor = nil
        testableUserDefaults = nil
        super.tearDown()
    }

    func test__empty_prefix() {
        adaptor = UserDefaultsStorage(prefix: "")
        adaptor.userDefaults = testableUserDefaults as UserDefaultsProtocol
        storage = AnyStorage(adaptor)
        let _ = storage["hello"]
        XCTAssertEqual(testableUserDefaults.didReadObjectForKey, "\(adaptor.prefix).hello")
    }

    func test__read_when_no_items_exit() {
        let result = storage["hello"]
        XCTAssertEqual(testableUserDefaults.didReadObjectForKey, "\(adaptor.prefix).hello")
        XCTAssertNil(result)
        XCTAssertEqual(storage.values.count, 0)
    }

    func test__write_then_read() {
        storage["Foo"] = ArchivableTestFeature(id: "Foo", title: "foo")
        XCTAssertEqual(storage.values.count, 1)
        let result = storage["Foo"]
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id ?? "Wrong", "Foo")
    }

    func test__write_then_remove() {
        storage["Foo"] = ArchivableTestFeature(id: "Foo", title: "foo")
        XCTAssertEqual(storage.values.count, 1)
        storage["Foo"] = nil
        let result = storage["Foo"]
        XCTAssertNil(result)
        XCTAssertEqual(storage.values.count, 0)
    }

    func test__remove_all_items() {
        storage["Foo"] = ArchivableTestFeature(id: "Foo", title: "foo")
        storage["Bar"] = ArchivableTestFeature(id: "Bar", title: "bar")
        storage.removeAll()
        XCTAssertEqual(storage.values.count, 0)
    }
}




