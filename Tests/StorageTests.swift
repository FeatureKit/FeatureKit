//
//  StorageTests.swift
//  Features
//
//  Created by Daniel Thorpe on 03/07/2016.
//
//

import XCTest
@testable import Features

class TestableUserDefaults: UserDefaultsProtocol {

    var objects: [String: AnyObject] = [:]

    var didReadObjectForKey: String? = .None
    var didSetObjectForKey: String? = .None
    var didRemoveObjectForKey: String? = .None
    var didGetDictionaryRepresentation = false

    func objectForKey(key: String) -> AnyObject? {
        didReadObjectForKey = key
        return objects[key]
    }

    func setObject(object: AnyObject?, forKey key: String) {
        didSetObjectForKey = key
        objects[key] = object
    }

    func removeObjectForKey(key: String) {
        didRemoveObjectForKey = key
        objects.removeValueForKey(key)
    }

    func dictionaryRepresentation() -> [String: AnyObject] {
        didGetDictionaryRepresentation = true
        return objects
    }
}

class ArchivableTestFeature: NSObject, NSCoding, FeatureProtocol {

    typealias FeatureIdentifier = String

    let id: String
    var parent: String? = .None
    var editable: Bool = false
    var available: Bool = false

    init(id: String, parent: String? = .None, available: Bool = false) {
        self.id = id
        self.parent = parent
        self.available = available
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        guard let
            identifier = aDecoder.decodeObjectForKey("id") as? String
        else { return nil }

        id = identifier
        parent = aDecoder.decodeObjectForKey("parent") as? String
        editable = aDecoder.decodeBoolForKey("editable")
        available = aDecoder.decodeBoolForKey("available")
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(available, forKey: "available")
        aCoder.encodeBool(editable, forKey: "editable")
        aCoder.encodeObject(parent, forKey: "parent")
        aCoder.encodeObject(id, forKey: "id")
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
        storage["Foo"] = ArchivableTestFeature(id: "Foo")
        XCTAssertEqual(storage.values.count, 1)
        let result = storage["Foo"]
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id ?? "Wrong", "Foo")
    }

    func test__write_then_remove() {
        storage["Foo"] = ArchivableTestFeature(id: "Foo")
        XCTAssertEqual(storage.values.count, 1)
        storage["Foo"] = nil
        let result = storage["Foo"]
        XCTAssertNil(result)
        XCTAssertEqual(storage.values.count, 0)
    }

    func test__remove_all_items() {
        storage["Foo"] = ArchivableTestFeature(id: "Foo")
        storage["Bar"] = ArchivableTestFeature(id: "Bar")
        storage.removeAll()
        XCTAssertEqual(storage.values.count, 0)
    }
}




