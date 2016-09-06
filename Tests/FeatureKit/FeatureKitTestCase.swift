//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import ValueCoding
@testable import FeatureKit

enum TestFeatureId: String, FeatureIdentifier, Comparable, ValueCoding {
    typealias Coder = RawRepresentableStringCoder<TestFeatureId>

    case Foo = "Foo"
    case Bar = "Bar"
    case Bat = "Bat"
    case Baz = "Baz"
    case Fat = "Fat"
    case Hat = "Hat"
}

enum TestFeaturesError<ID: FeatureIdentifier>: ErrorType {
    case FeatureNotDefinied(ID)
}

typealias TestFeature = Feature<TestFeatureId>
typealias TestFeatureService = FeatureService<TestFeature>

class FeatureKitTestCase: XCTestCase {

    var service: TestFeatureService!

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func createFeatures() -> [TestFeature] {
        return [
            TestFeature(id: .Foo, title: "foo", defaultAvailability: true, currentAvailability: true),
            TestFeature(id: .Bar, title: "bar", defaultAvailability: true, currentAvailability: false),
            TestFeature(id: .Bat, title: "bat", defaultAvailability: false, currentAvailability: true),
            TestFeature(id: .Baz, parent: .Bat, title: "baz", defaultAvailability: false, currentAvailability: false)
        ]
    }

    func setupServiceManually() {
        service = TestFeatureService().set(features: createFeatures())
    }

    func setupServiceFromJSON() {
        service = TestFeatureService()

        let mapper = TestFeature.mapper(searchForKey: "features")

        do {
            guard let path = NSBundle(forClass: self.dynamicType).pathForResource("Features", ofType: "json") else { return }

            let data = try NSData(contentsOfFile: path, options: [])

            let features = try mapper.map(data)

            service.set(features: features)
        }
        catch { }
    }
}