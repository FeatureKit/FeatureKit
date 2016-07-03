//
//  ServiceTests.swift
//  Features
//
//  Created by Daniel Thorpe on 03/07/2016.
//
//

import XCTest
import ValueCoding
@testable import Features

class FeatureIdCoder: NSObject, NSCoding, CodingType {
    let value: FeatureId

    required init(_ v: FeatureId) {
        self.value = v
    }

    required init?(coder aDecoder: NSCoder) {
        guard let
            raw = aDecoder.decodeObjectForKey("value") as? String,
            value = FeatureId(rawValue: raw)
        else { return nil }
        self.value = value
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.rawValue, forKey: "value")
    }
}

class FeatureCoder: NSObject, NSCoding, CodingType {
    let value: Feature

    required init(_ v: Feature) {
        self.value = v
    }

    required init?(coder aDecoder: NSCoder) {
        guard let id = FeatureId.decode(aDecoder.decodeObjectForKey("id"))
        else { return nil }

        value = Feature(
            id: id,
            defaultAvailable: aDecoder.decodeBoolForKey("defaultAvailable"),
            currentAvailable: aDecoder.decodeBoolForKey("currentAvailable")
        )
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.id.encoded, forKey: "id")
        aCoder.encodeBool(value.defaultAvailable, forKey: "defaultAvailable")
        aCoder.encodeBool(value.currentAvailable, forKey: "currentAvailable")
    }
}

extension FeatureId: ValueCoding {
    typealias Coder = FeatureIdCoder
}

extension Feature: ValueCoding {
    typealias Coder = FeatureCoder
}

class ServiceTests: XCTestCase {

    var testableUserDefaults: TestableUserDefaults!
    var adaptor: UserDefaultsAdaptor<Feature.Coder>!
    var storage: AnyValueStorage<Feature>!
    var service: Service<Feature>!

    override func setUp() {
        super.setUp()
        testableUserDefaults = TestableUserDefaults()
        adaptor = UserDefaultsAdaptor()
        adaptor.userDefaults = testableUserDefaults as UserDefaultsProtocol
        storage = AnyValueStorage(adaptor)
        service = Service(storage: storage)
    }

    override func tearDown() {
        testableUserDefaults = nil
        adaptor = nil
        service = nil
        super.tearDown()
    }

    func createFeatures() -> [Feature] {
        return [
            Feature(id: .Foo, defaultAvailable: true, currentAvailable: true),
            Feature(id: .Bar, defaultAvailable: true, currentAvailable: false),
            Feature(id: .Bat, defaultAvailable: false, currentAvailable: true),
            Feature(id: .Baz, defaultAvailable: false, currentAvailable: false)
        ]
    }

    func test__initialize_with_storage() {
        XCTAssertEqual(service.features.count, 0)
    }

    func test__set_storage_to_user_defaults() {
        service = Service().setStorageToUserDefaults()
        XCTAssertEqual(service.features.count, 0)
    }

    func test__write_read_to_value_storage() {
        storage.write(createFeatures())
        service = Service(storage: storage)
        XCTAssertEqual(service.features.count, 4)
    }

    func test__removeStorage_removes_all_items() {
        service.removeStorage()
        XCTAssertEqual(testableUserDefaults.didRemoveObjectForKey, adaptor.key)
    }

}
