//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import FeatureKit

public struct FeatureViewModel: Equatable {
    public let title: String
    public let isEditable: Bool
    public let isOn: Bool
    public let isToggled: Bool
}

public func == (lhs: FeatureViewModel, rhs: FeatureViewModel) -> Bool {
    return (lhs.title == rhs.title) && (lhs.isOn == rhs.isOn) && (lhs.isToggled == rhs.isToggled)
}

public extension DataSourceProtocol {

    func featureViewModel(atIndex index: Int, inSection sectionIndex: Int) -> FeatureViewModel {
        let f = feature(atIndex: index, inSection: sectionIndex)
        return FeatureViewModel(title: f.title, isEditable: f.isEditable, isOn: f.isAvailable, isToggled: f.isToggled)
    }
}