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

    func test__number_of_groups() {
        XCTAssertEqual(dataSource.numberOfGroups, 3)
    }

    func test__number_of_features_in_groups() {
        XCTAssertEqual(dataSource.numberOfFeaturesInGroupAtIndex(0), 1) // Bar
        XCTAssertEqual(dataSource.numberOfFeaturesInGroupAtIndex(1), 2) // Bat, Baz
        XCTAssertEqual(dataSource.numberOfFeaturesInGroupAtIndex(2), 1) // Foo
    }

    func test__features_in_group() {
        XCTAssertEqual(dataSource.featureAtIndex(0, inGroup: 0).id, TestFeatureId.Bar)
        XCTAssertEqual(dataSource.featureAtIndex(0, inGroup: 1).id, TestFeatureId.Bat)
        XCTAssertEqual(dataSource.featureAtIndex(1, inGroup: 1).id, TestFeatureId.Baz)
        XCTAssertEqual(dataSource.featureAtIndex(0, inGroup: 2).id, TestFeatureId.Foo)
    }
}
