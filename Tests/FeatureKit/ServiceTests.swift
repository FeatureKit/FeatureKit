//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import ValueCoding
@testable import FeatureKit

class ServiceTests: FeatureKitTestCase {

    var testableUserDefaults: TestableUserDefaults!
    var adaptor: UserDefaultsStorage<TestFeature.Identifier, TestFeature.Coder>!
    var storage: AnyValueStorage<TestFeature.Identifier, TestFeature>!

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
        super.tearDown()
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

    func test__load_from_url() {
        guard let path = NSBundle(forClass: self.dynamicType).pathForResource("Features", ofType: "json") else {
            XCTFail("Missing or invalid JSON file"); return
        }
        let url = NSURL(fileURLWithPath: path)

        service = TestFeatureService()
        XCTAssertEqual(service.features.count, 0)

        let expectation = expectationWithDescription("Test: \(#file) \(#line)")
        service.load(url, completion: expectation.fulfill)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertEqual(service.features.count, 6)
    }
}
