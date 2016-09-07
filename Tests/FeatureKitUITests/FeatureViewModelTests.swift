//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import FeatureKit
@testable import FeatureKitUI

class FeatureKitViewModelTests: FeatureKitTestCase {

    var dataSource: DataSource<TestFeatureService>!

    override func setUp() {
        super.setUp()
        setupServiceManually()
        dataSource = DataSource(service: service)
    }

    func test__access_view_model() {
        let model = dataSource.featureViewModel(atIndex: 0, inSection: 0)
        XCTAssertEqual(model.title, "bar")
        XCTAssertEqual(model.isOn, false)
        XCTAssertEqual(model.isOverridden, true)
    }

    func test__view_model_equality() {
        XCTAssertEqual(dataSource.featureViewModel(atIndex: 0, inSection: 0), dataSource.featureViewModel(atIndex: 0, inSection: 0))
    }
}