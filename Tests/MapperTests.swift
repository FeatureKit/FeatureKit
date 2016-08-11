//
//  FeatureKit
//
//  Created by Daniel Thorpe on 11/08/2016.
//
//

import Foundation
import XCTest
@testable import Features

struct AppendExclamation: MapperProtocol {
    func map(input: String) -> String {
        return "\(input)!"
    }
}

struct AppendQuestionMark: MapperProtocol {
    func map(input: String) -> String {
        return "\(input)?"
    }
}

class MapperTests: XCTestCase {

    func test__any_mapper() {
        let mapper = AnyMapper(AppendExclamation())
        XCTAssertEqual(mapper.map("Hello"), "Hello!")
    }

    func test__staged_mapper() {
        let mapper = AnyMapper(AppendExclamation()).add(AppendQuestionMark())
        XCTAssertEqual(mapper.map("Hello"), "Hello!?")
    }
}

