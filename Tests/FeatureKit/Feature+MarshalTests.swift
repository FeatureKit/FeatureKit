//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import Marshal
@testable import FeatureKit

class JSONFeatureMapperTests: XCTestCase {

    func test__feature_with_no_parent() {
        do {
            let feature = try TestFeature(object: ["id": "Foo", "title": "This is a title", "available": true])
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
            let feature = try TestFeature(object: ["id": "Bar", "parent": "Foo", "title": "This is a different title", "available": true])
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
                feature = try TestFeature(object: ["id": "Hat", "parent": "Fat", "title": "This is a another title", "editable": true, "defaultAvailable": false, "available": true])
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
            let _ = try TestFeature(object: ["parent": "Foo", "title": "This is a different title", "available": true])
        }
        catch MarshalError.keyNotFound { /* passing test */ }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }

    func test__throws_error_if_no_id_or_title() {
        do {
            let _ = try TestFeature(object: ["parent": "Foo", "available": true])
        }
        catch MarshalError.keyNotFound { /* passing test */ }
        catch { XCTFail("Caught unexpected error: \(error)") }
    }
 }
