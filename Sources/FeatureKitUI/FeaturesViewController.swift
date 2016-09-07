//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import FeatureKit

struct FeatureViewModel: Equatable {
    let title: String
    let isEditable: Bool
    let isOn: Bool
    let isToggled: Bool
}

class FeatureCell: UITableViewCell {

    static let identifier = "feature cell identififer"

    var toggle: UISwitch

    static func configure(cell cell: UITableViewCell, withFeature feature: FeatureViewModel) {
        cell.textLabel?.text = feature.title
        if let cell = cell as? FeatureCell {
            cell.toggle.on = feature.isOn
            cell.toggle.enabled = feature.isEditable
            cell.toggle.onTintColor = feature.isToggled ? UIColor.redColor() : nil
            cell.toggle.tintColor = cell.toggle.onTintColor
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        toggle = UISwitch(frame: CGRect.zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        accessoryView = toggle
    }

    required init?(coder aDecoder: NSCoder) {
        toggle = UISwitch(frame: CGRect.zero)
        super.init(coder: aDecoder)
        selectionStyle = .None
        accessoryView = toggle
    }
}

public class FeaturesViewController<Service: FeatureServiceProtocol where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable>: UIViewController {

    let tableViewDataSource: TableViewDataSource<Service>
    var tableView: UITableView!

    var dataSource: DataSource<Service> {
        return tableViewDataSource.dataSource
    }

    var service: Service {
        return dataSource.service
    }

    public init(service: Service) {
        tableViewDataSource = TableViewDataSource(dataSource: DataSource(service: service))
        super.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {
        let __view = UIView(frame: UIScreen.mainScreen().bounds)
        let __tableView = UITableView(frame: __view.bounds, style: tableViewDataSource.tableViewStyle)
        __view.addSubview(__tableView)

        view = __view
        tableView = __tableView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutMargins = UIEdgeInsetsZero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        configure(tableView: tableView)
    }

    func configure(tableView tableView: UITableView) {
        tableView.registerClass(FeatureCell.self, forCellReuseIdentifier: FeatureCell.identifier)
        tableView.dataSource = tableViewDataSource
    }
}

// MARK: - TableViewDataSource

internal extension DataSourceStyle {

    var tableViewStyle: UITableViewStyle {
        switch self {
        case .basic: return UITableViewStyle.Plain
        case .grouped: return UITableViewStyle.Grouped
        }
    }
}


class TableViewDataSource<Service: FeatureServiceProtocol where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable>: NSObject, UITableViewDataSource {
    private typealias GetCellBlock = (fromTableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell

    private let dataSource: DataSource<Service>
    private let getCell: GetCellBlock

    var tableViewStyle: UITableViewStyle {
        return dataSource.style.tableViewStyle
    }

    init(dataSource: DataSource<Service>) {
        self.dataSource = dataSource
        getCell = { $0.dequeueReusableCellWithIdentifier(FeatureCell.identifier, forIndexPath: $1) }
        super.init()
    }

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections
    }

    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfFeatures(inSection: section)
    }

    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(fromTableView: tableView, atIndexPath: indexPath)
        let viewModel = dataSource.featureViewModel(atIndex: indexPath.item, inSection: indexPath.section)
        FeatureCell.configure(cell: cell, withFeature: viewModel)
        return cell
    }
}

// MARK: - View Model

func == (lhs: FeatureViewModel, rhs: FeatureViewModel) -> Bool {
    return (lhs.title == rhs.title) && (lhs.isOn == rhs.isOn) && (lhs.isToggled == rhs.isToggled)
}

extension DataSourceProtocol {

    func featureViewModel(atIndex index: Int, inSection sectionIndex: Int) -> FeatureViewModel {
        let f = feature(atIndex: index, inSection: sectionIndex)
        return FeatureViewModel(title: f.title, isEditable: f.isEditable, isOn: f.isAvailable, isToggled: f.isToggled)
    }
}
