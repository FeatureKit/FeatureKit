//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import ValueCoding
@testable import FeatureKit

class FeaturesTests: FeatureKitTestCase {

    override func setUp() {
        super.setUp()
        setupServiceManually()
    }

    func test__get_feature_with_exits() {
        XCTAssertEqual(service.feature(withIdentifier: .Foo)?.id, TestFeatureId.Foo)
    }

    func test__default_editable_value_is_false() {
        XCTAssertFalse(service.feature(withIdentifier: .Foo)?.isEditable ?? true)
    }

    func test__access_feature_available() {
        XCTAssertTrue(service.isAvailable(withIdentifier: .Foo))
    }

    func test__access_feature_not_available() {
        XCTAssertFalse(service.isAvailable(withIdentifier: .Bar))
    }

    func test__access_undefined_feature_not_available() {
        XCTAssertFalse(service.isAvailable(withIdentifier: .Fat))
    }

    func test__access_not_available_if_parent_not_available() {
        XCTAssertFalse(service.isAvailable(withIdentifier: .Baz))
    }

    func test__access_parent_when_defined_but_nil() {
        XCTAssertNil(service.parent(ofFeatureWithIdentifier: .Foo))
    }

    func test__access_parent_when_not_defined_nil() {
        XCTAssertNil(service.parent(ofFeatureWithIdentifier: .Fat))
    }

    func test__access_parent_when_parent_is_not_defined_nil() {
        XCTAssertNil(service.parent(ofFeatureWithIdentifier: .Hat))
    }
}


