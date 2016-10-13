//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import UIKit
import FeatureKit

public class CustomTableViewDataSource<Cell: UITableViewCell, Service: FeatureServiceProtocol>: NSObject, UITableViewDataSource where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable {

    public typealias ConfigurationBlock = (UITableViewCell, FeatureViewModel) -> Void

    private typealias GetCellBlock = (UITableView, NSIndexPath) -> UITableViewCell

    private let dataSource: DataSource<Service>
    private let configure: ConfigurationBlock

    private var getCell: GetCellBlock

    public init(service: Service, forTableView tableView: UITableView, configurationBlock: ConfigurationBlock) {
        dataSource = DataSource(service: service)
        configure = configurationBlock
        let identifier = "feature-cell-identifier"
        getCell = { $0.dequeueReusableCellWithIdentifier(identifier, forIndexPath: $1) }
        super.init()
        tableView.registerClass(Cell.self, forCellReuseIdentifier: identifier)
        tableView.dataSource = self
    }

    @objc public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections
    }

    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfFeatures(inSection: section)
    }

    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, indexPath)
        let viewModel = dataSource.featureViewModel(atIndex: indexPath.item, inSection: indexPath.section)
        configure(cell, viewModel)
        return cell
    }
}

public class FeatureCell: UITableViewCell {
    var toggle: UISwitch

    static func configure(cell: UITableViewCell, withFeature feature: FeatureViewModel) {
        cell.textLabel?.text = feature.title
        if let cell = cell as? FeatureKitUI.FeatureCell {
            cell.toggle.on = feature.isOn
            cell.toggle.enabled = feature.isEditable
            cell.toggle.onTintColor = feature.isToggled ? UIColor.redColor() : nil
            cell.toggle.tintColor = cell.toggle.onTintColor
        }
    }

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        toggle = UISwitch(frame: CGRect.zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        accessoryView = toggle
    }

    public required init?(coder aDecoder: NSCoder) {
        toggle = UISwitch(frame: CGRect.zero)
        super.init(coder: aDecoder)
        selectionStyle = .None
        accessoryView = toggle
    }
}

public class TableViewDataSource<Service: FeatureServiceProtocol>: CustomTableViewDataSource<FeatureCell, Service> where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable {

    public init(service: Service, forTableView tableView: UITableView) {
        super.init(service: service, forTableView: tableView, configurationBlock: FeatureCell.configure)
    }
}
