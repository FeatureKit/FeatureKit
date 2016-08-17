//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import ValueCoding
@testable import FeatureKit

enum TestFeatureId: String, FeatureIdentifier, ValueCoding {
    typealias Coder = RawRepresentableStringCoder<TestFeatureId>

    case Foo = "Foo"
    case Bar = "Bar"
    case Bat = "Bat"
    case Baz = "Baz"
    case Fat = "Fat"
    case Hat = "Hat"
}

enum TestFeaturesError<ID: FeatureIdentifier>: ErrorType {
    case FeatureNotDefinied(ID)
}

typealias TestFeature = Feature<TestFeatureId>
typealias TestFeatureService = FeatureService<TestFeature>

class TestFeatures: XCTestCase {

    var service: TestFeatureService!

    override func setUp() {
        super.setUp()
        service = TestFeatureService([
            .Foo: TestFeature(id: .Foo, title: "foo", defaultAvailability: true, currentAvailability: true),
            .Bar: TestFeature(id: .Bar, title: "bar", defaultAvailability: true, currentAvailability: false),
            .Bat: TestFeature(id: .Bat, title: "bat", defaultAvailability: false, currentAvailability: true),
            .Baz: TestFeature(id: .Baz, title: "baz", defaultAvailability: false, currentAvailability: false)
        ])
    }

    func test__get_feature_with_exits() {
        XCTAssertEqual(service.feature(.Foo)?.id, TestFeatureId.Foo)
    }

    func test__default_editable_value_is_false() {
        XCTAssertFalse(service.feature(.Foo)?.editable ?? true)
    }

    func test__access_feature_available() {
        XCTAssertTrue(service.available(.Foo))
    }

    func test__access_feature_not_available() {
        XCTAssertFalse(service.available(.Bar))
    }

    func test__access_undefined_feature_not_available() {
        XCTAssertFalse(service.available(.Fat))
    }

    func test__access_not_available_if_parent_not_available() {
        XCTAssertFalse(service.available(.Baz))
    }

    func test__access_parent_when_defined_but_nil() {
        XCTAssertNil(service.parent(.Foo))
    }

    func test__access_parent_when_not_defined_nil() {
        XCTAssertNil(service.parent(.Fat))
    }

    func test__access_parent_when_parent_is_not_defined_nil() {
        XCTAssertNil(service.parent(.Hat))
    }
}


