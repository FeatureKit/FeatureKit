//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import FeatureKit
@testable import FeatureKitUI

class TestableTable: UITableView {

    var didRegisterClassWithIdentifier: (AnyClass?, String)? = .None
    var didRegisterNibWithIdentifier: (UINib?, String)? = .None

    var didRegisterSupplementaryClassWithIdentifier: (AnyClass?, String)? = .None
    var didRegisterSupplementaryNibWithIdentifier: (UINib?, String)? = .None

    override func registerClass(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        didRegisterClassWithIdentifier = (cellClass, identifier)
        super.registerClass(cellClass, forCellReuseIdentifier: identifier)
    }

    override func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
        didRegisterNibWithIdentifier = (nib, identifier)
        super.registerNib(nib, forCellReuseIdentifier: identifier)
    }

    override func registerClass(aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        didRegisterSupplementaryClassWithIdentifier = (aClass, identifier)
        super.registerClass(aClass, forHeaderFooterViewReuseIdentifier: identifier)
    }

    override func registerNib(nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
        didRegisterSupplementaryNibWithIdentifier = (nib, identifier)
        super.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    override func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: .Default, reuseIdentifier: identifier)
    }

    override func dequeueReusableHeaderFooterViewWithIdentifier(identifier: String) -> UITableViewHeaderFooterView? {
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
        XCTAssertEqual(tableViewDataSource.numberOfSectionsInTableView(tableView), 3)
    }

    func test__number_of_rows_in_section() {
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 1), 2)
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 2), 1)
    }

    func test__cell_is_configured_feature_cell() {
        let cell = tableViewDataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(cell.textLabel?.text ?? "this is incorrect", "bar")        
    }
}
