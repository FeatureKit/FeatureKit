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

struct TestFeaturesService: FeatureServiceType {

    func feature(identifier: TestFeatureId) throws -> TestFeature {
        switch identifier {
        case .Foo:
            return TestFeature(identifier: identifier, defaultAvailable: true, currentAvailable: true)
        case .Bar:
            return TestFeature(identifier: identifier, defaultAvailable: true, currentAvailable: false)
        case .Bat:
            return TestFeature(identifier: identifier, defaultAvailable: false, currentAvailable: true)
        case .Baz:
            return TestFeature(identifier: identifier, defaultAvailable: false, currentAvailable: false)
        default:
            throw TestFeaturesError.FeatureNotDefinied(identifier)
        }
    }
}

class TestFeatures: XCTestCase {

    var service: TestFeaturesService!

    override func setUp() {
        super.setUp()
        service = TestFeaturesService()
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
