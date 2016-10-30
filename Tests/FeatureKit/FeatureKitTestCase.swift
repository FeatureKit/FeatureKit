//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import XCTest
import ValueCoding
import Marshal
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

enum TestFeaturesError<ID: FeatureIdentifier>: Error {
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

        do {
            guard let path = Bundle(for: type(of: self)).url(forResource: "Features", withExtension: "json") else { return }

            let data = try Data(contentsOf: path, options: [])
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! MarshalDictionary
            let features: [TestFeature] = try json.value(for: "features")
            service.set(features: features)
        }
        catch { }
    }
}
