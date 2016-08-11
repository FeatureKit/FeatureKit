//
//  FeatureKit
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import XCTest
import ValueCoding
@testable import Features

class ServiceTests: XCTestCase {

    var testableUserDefaults: TestableUserDefaults!
    var adaptor: UserDefaultsStorage<TestFeature.Identifier, TestFeature.Coder>!
    var storage: AnyValueStorage<TestFeature.Identifier, TestFeature>!
    var service: TestFeatureService!

    override func setUp() {
        super.setUp()
        testableUserDefaults = TestableUserDefaults()
        adaptor = UserDefaultsStorage()
        adaptor.userDefaults = testableUserDefaults as UserDefaultsProtocol
        storage = AnyValueStorage(adaptor)
        service = FeatureService(storage: storage)
    }

    override func tearDown() {
        testableUserDefaults = nil
        adaptor = nil
        service = nil
        super.tearDown()
    }

    func createFeatures() -> [TestFeature] {
        return [
            TestFeature(id: .Foo, title: "foo", defaultAvailability: true, currentAvailability: true),
            TestFeature(id: .Bar, title: "bar", defaultAvailability: true, currentAvailability: false),
            TestFeature(id: .Bat, title: "bat", defaultAvailability: false, currentAvailability: true),
            TestFeature(id: .Baz, title: "baz", defaultAvailability: false, currentAvailability: false)
        ]
    }

    func test__initialize_with_storage() {
        XCTAssertEqual(service.features.count, 0)
    }

    func test__set_storage_to_user_defaults() {
        service = TestFeatureService().setStorageToUserDefaults()
        XCTAssertEqual(service.features.count, 0)
    }

    func test__write_read_to_value_storage() {
        createFeatures().forEach { storage[$0.id] = $0 }
        service = TestFeatureService(storage: storage)
        XCTAssertEqual(service.features.count, 4)
    }
}
