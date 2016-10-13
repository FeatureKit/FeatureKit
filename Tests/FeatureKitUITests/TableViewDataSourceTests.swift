//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import FeatureKit
@testable import FeatureKitUI

class TestableTable: UITableView {

    var didRegisterClassWithIdentifier: (AnyClass?, String)? = .none
    var didRegisterNibWithIdentifier: (UINib?, String)? = .none

    var didRegisterSupplementaryClassWithIdentifier: (AnyClass?, String)? = .none
    var didRegisterSupplementaryNibWithIdentifier: (UINib?, String)? = .none

    override func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        didRegisterClassWithIdentifier = (cellClass, identifier)
        super.register(cellClass, forCellReuseIdentifier: identifier)
    }

    override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        didRegisterNibWithIdentifier = (nib, identifier)
        super.register(nib, forCellReuseIdentifier: identifier)
    }

    override func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        didRegisterSupplementaryClassWithIdentifier = (aClass, identifier)
        super.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
    }

    override func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
        didRegisterSupplementaryNibWithIdentifier = (nib, identifier)
        super.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: identifier)
    }

    override func dequeueReusableHeaderFooterView(withIdentifier identifier: String) -> UITableViewHeaderFooterView? {
        return UITableViewHeaderFooterView(reuseIdentifier: identifier)
    }
}

class TableViewDataSourceTests: FeatureKitTestCase {
    typealias TypeUnderTest = TableViewDataSource<TestFeatureService>

    var tableView: TestableTable!
    var didConfigureCell: (UITableViewCell, FeatureViewModel)?
    var dataSource: DataSource<TestFeatureService>!
    var tableViewDataSource: TypeUnderTest!

    override func setUp() {
        super.setUp()
        setupServiceManually()
        tableView = TestableTable()
        dataSource = DataSource(service: service)
        tableViewDataSource = TypeUnderTest(dataSource: dataSource)
    }

    func test__number_of_sections() {
        XCTAssertEqual(tableViewDataSource.numberOfSections(in: tableView), 3)
    }

    func test__number_of_rows_in_section() {
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 1), 2)
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 2), 1)
    }

    func test__cell_is_configured_feature_cell() {
        let cell = tableViewDataSource.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text ?? "this is incorrect", "bar")        
    }
}
