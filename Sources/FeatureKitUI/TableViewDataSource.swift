//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import UIKit
import FeatureKit

public class CustomTableViewDataSource<Cell: UITableViewCell, Service: FeatureServiceProtocol where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable>: NSObject, UITableViewDataSource {

    public typealias ConfigurationBlock = (cell: Cell, feature: FeatureViewModel) -> Void

    private typealias GetCellBlock = (fromTableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell

    private let dataSource: DataSource<Service>
    private let configure: ConfigurationBlock

    private var getCell: GetCellBlock? = nil

    public init(service: Service, configurationBlock: ConfigurationBlock) {
        dataSource = DataSource(service: service)
        configure = configurationBlock
    }

    public func registerClass(aClass: AnyClass, inTableView tableView: UITableView, withCellIdentififer identifier: String) {
        tableView.registerClass(aClass, forCellReuseIdentifier: identifier)
        getCell = { $0.dequeueReusableCellWithIdentifier(identifier, forIndexPath: $1) }
    }

    @objc public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections
    }

    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfFeatures(inSection: section)
    }

    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell?(fromTableView: tableView, atIndexPath: indexPath) as? Cell ?? Cell()
        let viewModel = dataSource.featureViewModel(atIndex: indexPath.item, inSection: indexPath.section)
        configure(cell: cell, feature: viewModel)
        return cell
    }
}

