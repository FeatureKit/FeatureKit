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

class CustomTableViewDataSourceTests: FeatureKitTestCase {

    typealias TypeUnderTest = CustomTableViewDataSource<UITableViewCell, TestFeatureService>
    var tableView: TestableTable!
    var didConfigureCell: (UITableViewCell, FeatureViewModel)?
    var tableViewDataSource: TypeUnderTest!

    override func setUp() {
        super.setUp()
        setupServiceManually()
        tableView = TestableTable()
        didConfigureCell = nil
        tableViewDataSource = TypeUnderTest(service: service) { self.didConfigureCell = ($0, $1) }
    }

    func test__register_class_actually_registers_class_on_table_view() {
        let identifier = "cell-identifier"
        tableViewDataSource.registerClass(UITableViewCell.self, inTableView: tableView, withCellIdentififer: identifier)
        guard let (_, registeredId) = tableView.didRegisterClassWithIdentifier else {
            XCTFail("Did not register cell on table view"); return
        }
        XCTAssertEqual(registeredId, identifier)
    }

    func test__number_of_sections() {
        XCTAssertEqual(tableViewDataSource.numberOfSectionsInTableView(tableView), 3)
    }

    func test__number_of_rows_in_section() {
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 1), 2)
        XCTAssertEqual(tableViewDataSource.tableView(tableView, numberOfRowsInSection: 2), 1)
    }


    func test__cell_for_row_at_indexpath() {
        tableViewDataSource.registerClass(UITableViewCell.self, inTableView: tableView, withCellIdentififer: "identifier")
        let cell = tableViewDataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        guard let (configuredCell, viewModel) = didConfigureCell else {
            XCTFail("Did not configure cell"); return
        }
        XCTAssertEqual(cell, configuredCell)
        XCTAssertEqual(viewModel.title, "bar")
        XCTAssertEqual(viewModel.isOn, false)
        XCTAssertEqual(viewModel.isOverridden, true)
    }
}


