//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
@testable import FeatureKit

class JSONFeatureMapperTests: XCTestCase {

    func test__feature_with_no_parent() {
        do {
            let feature = try TestFeature.create(from: ["id": "Foo", "title": "This is a title", "defaultAvailability": true])
            XCTAssertEqual(feature.id, TestFeatureId.Foo)
            XCTAssertNil(feature.parent)
            XCTAssertEqual(feature.title, "This is a title")
            XCTAssertEqual(feature.isEditable, false)
            XCTAssertEqual(feature.defaultAvailability, true)
            XCTAssertEqual(feature.currentAvailability, true)
            XCTAssertEqual(feature.isAvailable, true)
            XCTAssertEqual(feature.isToggled, false)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__feature_with_parent() {
        do {
            let feature = try TestFeature.create(from: ["id": "Bar", "parent": "Foo", "title": "This is a different title", "defaultAvailability": true])
            XCTAssertEqual(feature.id, TestFeatureId.Bar)
            XCTAssertEqual(feature.parent, TestFeatureId.Foo)
            XCTAssertEqual(feature.title, "This is a different title")
            XCTAssertEqual(feature.isEditable, false)
            XCTAssertEqual(feature.defaultAvailability, true)
            XCTAssertEqual(feature.currentAvailability, true)
            XCTAssertEqual(feature.isAvailable, true)
            XCTAssertEqual(feature.isToggled, false)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }


    func test__feature_with_all_possible_fields() {
        var feature: TestFeature! = nil
        measure {
            do {
                feature = try TestFeature.create(from: ["id": "Hat", "parent": "Fat", "title": "This is a another title", "editable": true, "defaultAvailability": false, "currentAvailability": true])
            }
            catch { XCTFail("Caught unexpected error: \(error)") }
        }
        XCTAssertEqual(feature.id, TestFeatureId.Hat)
        XCTAssertEqual(feature.parent, TestFeatureId.Fat)
        XCTAssertEqual(feature.title, "This is a another title")
        XCTAssertEqual(feature.isEditable, true)
        XCTAssertEqual(feature.defaultAvailability, false)
        XCTAssertEqual(feature.currentAvailability, true)
        XCTAssertEqual(feature.isAvailable, true)
        XCTAssertEqual(feature.isToggled, true)
    }

    func test__throws_error_if_no_id() {
        do {
            let _ = try TestFeature.create(from: ["parent": "Foo", "title": "This is a different title", "defaultAvailability": true])
        }
        catch JSONError.keyNotFound("id") { /* passing test */ }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__throws_error_if_no_id_or_title() {
        do {
            let _ = try TestFeature.create(from: ["parent": "Foo", "defaultAvailability": true])
        }
        catch JSONError.keyNotFound("id") { /* passing test */ }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__data_mapper_with_single_feature() {
        let json = [ "features": [["id": "Foo", "title": "This is a title", "defaultAvailability": true]] ]

        // This is the mapper for NSData -> JSON -> JSON extrator -> Feature
        let mapper = TestFeature.mapper(searchForKey: "features")

        do {
            // Create thes NSData from the input JSON
            let data = try JSONSerialization.data(withJSONObject: json, options: [])

            // Map the data to a Features
            let features = try mapper.map(input: data)

            // Assert correctness
            XCTAssertEqual(features.count, 1)
            XCTAssertEqual(features.first?.id ?? TestFeatureId.Bar, TestFeatureId.Foo)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }


    func test__data_mapper_with_many_features() {

        // This is the mapper for NSData -> JSON -> JSON extrator -> Feature
        let mapper = TestFeature.mapper(searchForKey: "features")

        do {
            guard let path = Bundle(for: type(of: self)).url(forResource: "Features", withExtension: "json") else {
                XCTFail("Missing JSON file"); return
            }

            let data = try Data(contentsOf: path, options: [])

            // Map the data to a Features
            let features = try mapper.map(input: data)

            // Assert correctness
            verify(features: features)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__data_mapper_with_many_features_in_array() {

        // This is the mapper for NSData -> JSON -> JSON extrator -> Feature
        let mapper = TestFeature.mapper()

        do {
            guard let path = Bundle(for: type(of: self)).url(forResource: "FeaturesList", withExtension: "json") else {
                XCTFail("Missing JSON file"); return
            }

            let data = try Data(contentsOf: path, options: [])

            // Map the data to a Features
            let features = try mapper.map(input: data)

            verify(features: features)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func verify(features: [TestFeature]) {
        XCTAssertEqual(features.count, 6)
        XCTAssertEqual(features.map { $0.id }, [.Foo, .Fat, .Bar, .Bat, .Baz, .Hat])
    }
}
