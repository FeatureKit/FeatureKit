//
//  FeatureKit
//
//  Created by Daniel Thorpe on 11/08/2016.
//
//

import XCTest
@testable import Features

class JSONFeatureMapperTests: XCTestCase {

    func test__feature_with_no_parent() {
        do {
            let feature = try TestFeature.create(from: ["id": "Foo", "title": "This is a title", "defaultAvailability": true])
            XCTAssertEqual(feature.id, TestFeatureId.Foo)
            XCTAssertNil(feature.parent)
            XCTAssertEqual(feature.title, "This is a title")
            XCTAssertEqual(feature.editable, false)
            XCTAssertEqual(feature.defaultAvailability, true)
            XCTAssertEqual(feature.currentAvailability, true)
            XCTAssertEqual(feature.available, true)
            XCTAssertEqual(feature.toggled, false)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__feature_with_parent() {
        do {
            let feature = try TestFeature.create(from: ["id": "Bar", "parent": "Foo", "title": "This is a different title", "defaultAvailability": true])
            XCTAssertEqual(feature.id, TestFeatureId.Bar)
            XCTAssertEqual(feature.parent, TestFeatureId.Foo)
            XCTAssertEqual(feature.title, "This is a different title")
            XCTAssertEqual(feature.editable, false)
            XCTAssertEqual(feature.defaultAvailability, true)
            XCTAssertEqual(feature.currentAvailability, true)
            XCTAssertEqual(feature.available, true)
            XCTAssertEqual(feature.toggled, false)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }


    func test__feature_with_all_possible_fields() {
        var feature: TestFeature! = nil
        measureBlock {
            do {
                feature = try TestFeature.create(from: ["id": "Hat", "parent": "Fat", "title": "This is a another title", "editable": true, "defaultAvailability": false, "currentAvailability": true])
            }
            catch { XCTFail("Caught unexpected error: \(error)") }
        }
        XCTAssertEqual(feature.id, TestFeatureId.Hat)
        XCTAssertEqual(feature.parent, TestFeatureId.Fat)
        XCTAssertEqual(feature.title, "This is a another title")
        XCTAssertEqual(feature.editable, true)
        XCTAssertEqual(feature.defaultAvailability, false)
        XCTAssertEqual(feature.currentAvailability, true)
        XCTAssertEqual(feature.available, true)
        XCTAssertEqual(feature.toggled, true)
    }

    func test__throws_error_if_no_id() {
        do {
            let _ = try TestFeature.create(from: ["parent": "Foo", "title": "This is a different title", "defaultAvailability": true])
        }
        catch JSON.Error.keyNotFound("id") { /* passing test */ }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__throws_error_if_no_id_or_title() {
        do {
            let _ = try TestFeature.create(from: ["parent": "Foo", "defaultAvailability": true])
        }
        catch JSON.Error.keyNotFound("id") { /* passing test */ }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__data_mapper() {
        let json = [ "features": ["id": "Foo", "title": "This is a title", "defaultAvailability": true] ]

        let toJSON = AnyObjectCoercion<JSON.Fragment>()

        // This is the mapper for NSData -> JSON -> JSON extrator -> Feature
        let mapper = JSON.DataMapper()
            .append(toJSON)
            .append(JSON.Search(forKey: "features"))
            .append(toJSON)
            .append(TestFeature.mapper())

        do {
            // Create thes NSData from the input JSON
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: [])

            // Map the data to a single Feature
            let feature = try mapper.map(data)

            // Assert correctness
            XCTAssertEqual(feature.id, TestFeatureId.Foo)
        }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }
}
