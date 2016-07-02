//
//  FeaturesTests.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import XCTest
@testable import Features

enum TestFeatureId: String, FeatureIdentifier {
    case Foo = "Foo"
    case Bar = "Bar"
    case Bat = "Bat"
    case Baz = "Baz"
    case Fat = "Fat"
    case Hat = "Hat"
}

struct TestFeature: FeatureProtocol {
    let id: TestFeatureId
    var parent: TestFeatureId? {
        switch id {
        case .Foo, .Fat: return .None
        case .Bar: return .Foo
        case .Bat: return .Hat
        case .Baz: return .Bar
        case .Hat: return .Fat
        }
    }

    let defaultAvailable: Bool
    var currentAvailable: Bool

    var available: Bool {
        return currentAvailable
    }
}

enum TestFeaturesError<ID: FeatureIdentifier>: ErrorType {
    case FeatureNotDefinied(ID)
}

typealias TestFeatureService = Service<TestFeature>

class TestFeatures: XCTestCase {

    var service: TestFeatureService!

    override func setUp() {
        super.setUp()
        service = TestFeatureService([
            TestFeature(id: .Foo, defaultAvailable: true, currentAvailable: true),
            TestFeature(id: .Bar, defaultAvailable: true, currentAvailable: false),
            TestFeature(id: .Bat, defaultAvailable: false, currentAvailable: true),
            TestFeature(id: .Baz, defaultAvailable: false, currentAvailable: false)
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
