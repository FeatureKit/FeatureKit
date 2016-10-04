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

    static func configure(cell: UITableViewCell, withFeature feature: FeatureViewModel) {
        cell.textLabel?.text = feature.title
        if let cell = cell as? FeatureCell {
            cell.toggle.isOn = feature.isOn
            cell.toggle.isEnabled = feature.isEditable
            cell.toggle.onTintColor = feature.isToggled ? UIColor.red : nil
            cell.toggle.tintColor = cell.toggle.onTintColor
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        toggle = UISwitch(frame: CGRect.zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryView = toggle
    }

    required init?(coder aDecoder: NSCoder) {
        toggle = UISwitch(frame: CGRect.zero)
        super.init(coder: aDecoder)
        selectionStyle = .none
        accessoryView = toggle
    }
}

public class FeaturesViewController<Service: FeatureServiceProtocol>: UIViewController where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable {

    let tableViewDataSource: TableViewDataSource<Service>
    var tableView: UITableView!

    var dataSource: DataSource<Service> {
        return tableViewDataSource.dataSource
    }

    var service: Service {
        return dataSource.service
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(service: Service) {
        tableViewDataSource = TableViewDataSource(dataSource: DataSource(service: service))
        super.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {
        let __view = UIView(frame: UIScreen.main.bounds)
        let __tableView = UITableView(frame: __view.bounds, style: tableViewDataSource.tableViewStyle)
        __view.addSubview(__tableView)

        view = __view
        tableView = __tableView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutMargins = UIEdgeInsets.zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        configure(tableView: tableView)
    }

    func configure(tableView: UITableView) {
        tableView.register(FeatureCell.self, forCellReuseIdentifier: FeatureCell.identifier)
        tableView.dataSource = tableViewDataSource
    }
}

// MARK: - TableViewDataSource

internal extension DataSourceStyle {

    var tableViewStyle: UITableViewStyle {
        switch self {
        case .basic: return UITableViewStyle.plain
        case .grouped: return UITableViewStyle.grouped
        }
    }
}


class TableViewDataSource<Service: FeatureServiceProtocol>: NSObject, UITableViewDataSource where Service.Feature: MutableFeatureProtocol, Service.Feature.Identifier: Comparable {
    private typealias GetCellBlock = (UITableView, IndexPath) -> UITableViewCell

    fileprivate let dataSource: DataSource<Service>
    private let getCell: GetCellBlock

    var tableViewStyle: UITableViewStyle {
        return dataSource.style.tableViewStyle
    }

    init(dataSource: DataSource<Service>) {
        self.dataSource = dataSource
        getCell = { $0.dequeueReusableCell(withIdentifier: FeatureCell.identifier, for: $1) }
        super.init()
    }

    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections
    }

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfFeatures(inSection: section)
    }

    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, indexPath)
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
