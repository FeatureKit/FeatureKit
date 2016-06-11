//
//  FeaturesTests.swift
//  Features
//
//  Created by Daniel Thorpe on 11/06/2016.
//
//

import XCTest
@testable import Features

enum TestFeatureId: String, FeatureIdentifierType {
    case Foo = "Foo"
    case Bar = "Bar"
    case Bat = "Bat"
    case Baz = "Baz"
    case Fat = "Fat"
    case Hat = "Hat"

    var description: String { return rawValue }

}

struct TestFeature: FeatureType {
    let identifier: TestFeatureId
    var parent: TestFeatureId? {
        switch identifier {
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

enum TestFeaturesError<ID: FeatureIdentifierType>: ErrorType {
    case FeatureNotDefinied(ID)
}

class TestFeatures: XCTestCase {

    var service: FeatureService<TestFeature>!

    override func setUp() {
        super.setUp()
        service = FeatureService([
            TestFeature(identifier: .Foo, defaultAvailable: true, currentAvailable: true),
            TestFeature(identifier: .Bar, defaultAvailable: true, currentAvailable: false),
            TestFeature(identifier: .Bat, defaultAvailable: false, currentAvailable: true),
            TestFeature(identifier: .Baz, defaultAvailable: false, currentAvailable: false)
        ])
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
