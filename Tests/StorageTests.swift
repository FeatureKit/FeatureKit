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

class UserDefaultsAdaptorTests: XCTestCase {

    var testableUserDefaults: TestableUserDefaults!
    var adaptor: UserDefaultsAdaptor<ArchivableTestFeature>!

    override func setUp() {
        super.setUp()
        testableUserDefaults = TestableUserDefaults()
        adaptor = UserDefaultsAdaptor()
        adaptor.userDefaults = testableUserDefaults as UserDefaultsProtocol
    }

    override func tearDown() {
        testableUserDefaults = nil
        adaptor = nil
        super.tearDown()
    }

    func test__read_when_no_items_exit() {
        let storage = AnyStorage(adaptor)
        var result: [ArchivableTestFeature]? = .None
        storage.read { result = $0 }
        XCTAssertEqual(testableUserDefaults.didReadObjectForKey, adaptor.key)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count ?? 100, 0)
    }

    func test__write_then_read() {
        let storage = AnyStorage(adaptor)
        var result: [ArchivableTestFeature]? = .None
        storage.write([ArchivableTestFeature(id: "Foo")])
        storage.read { result = $0 }
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count ?? 0, 1)
    }

    func test__remove_all_items() {
        let storage = AnyStorage(adaptor)
        storage.write([ArchivableTestFeature(id: "Foo"), ArchivableTestFeature(id: "Bar")])
        storage.read { XCTAssertEqual($0.count, 2) }
        storage.removeAll()
        storage.read { XCTAssertEqual($0.count, 0) }
    }
}




