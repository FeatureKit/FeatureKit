//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
@testable import FeatureKit

class DataSourceTests: FeatureKitTestCase {

    var dataSource: DataSource<TestFeatureService>!

    override func setUp() {
        super.setUp()
        setupServiceManually()
        dataSource = DataSource(service: service)
    }

    func test__number_of_sections() {
        XCTAssertEqual(dataSource.numberOfSections, 3)
    }

    func test__number_of_features_in_section() {
        XCTAssertEqual(dataSource.numberOfFeatures(inSection: 0), 1) // Bar
        XCTAssertEqual(dataSource.numberOfFeatures(inSection: 1), 2) // Bat, Baz
        XCTAssertEqual(dataSource.numberOfFeatures(inSection: 2), 1) // Foo
    }

    func test__features_in_section() {
        XCTAssertEqual(dataSource.feature(atIndex: 0, inSection: 0).id, TestFeatureId.Bar)
        XCTAssertEqual(dataSource.feature(atIndex: 0, inSection: 1).id, TestFeatureId.Bat)
        XCTAssertEqual(dataSource.feature(atIndex: 1, inSection: 1).id, TestFeatureId.Baz)
        XCTAssertEqual(dataSource.feature(atIndex: 0, inSection: 2).id, TestFeatureId.Foo)
    }
}

class SpeciaEdgeCaseDataSource: FeatureKitTestCase {

    var dataSource: DataSource<TestFeatureService>!

    override func setUp() {
        super.setUp()
        setupServiceManually()
        dataSource = DataSource(service: service)
    }

    override func createFeatures() -> [TestFeature] {
        // Special edge case is where there are no parent features
        return [
            TestFeature(id: .Foo, title: "foo", defaultAvailability: true, currentAvailability: true),
            TestFeature(id: .Bar, title: "bar", defaultAvailability: true, currentAvailability: false),
            TestFeature(id: .Bat, title: "bat", defaultAvailability: false, currentAvailability: true),
            TestFeature(id: .Baz, title: "baz", defaultAvailability: false, currentAvailability: false)
        ]
    }

    func test__number_of_groups() {
        // When there are no parents, we want a single group
        XCTAssertEqual(dataSource.numberOfSections, 1)
    }

    func test__number_of_features_in_groups() {
        // When there are no parents, we want all features in one group
        XCTAssertEqual(dataSource.numberOfFeatures(inSection: 0), 4)
    }

    func test__features_in_group() {
        // Features are always sorted in order
        XCTAssertEqual(dataSource.feature(atIndex: 0, inSection: 0).id, TestFeatureId.Bar)
        XCTAssertEqual(dataSource.feature(atIndex: 1, inSection: 0).id, TestFeatureId.Bat)
        XCTAssertEqual(dataSource.feature(atIndex: 2, inSection: 0).id, TestFeatureId.Baz)
        XCTAssertEqual(dataSource.feature(atIndex: 3, inSection: 0).id, TestFeatureId.Foo)
    }
}
