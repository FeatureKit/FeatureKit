//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation
import XCTest
@testable import FeatureKit

struct AppendExclamation: Mappable {
    func map(input: String) -> String {
        return "\(input)!"
    }
}

struct AppendQuestionMark: Mappable {
    func map(input: String) -> String {
        return "\(input)?"
    }
}

struct CharacterCount: Mappable {
    func map(input: String) -> Int {
        return input.characters.count
    }
}


class MapperTests: XCTestCase {

    func test__any_mapper() {
        let mapper = AnyMapper(AppendExclamation())
        XCTAssertEqual(try! mapper.map(input: "Hello"), "Hello!")
    }

    func test__append_mappers() {
        let mapper = AnyMapper(AppendExclamation())
            .append(AppendQuestionMark())
            .append(CharacterCount())
        XCTAssertEqual(try! mapper.map(input: "Hello"), 7)
    }

    func test__any_object_coercion() {
        let mapper = AnyObjectCoercion<Data>()
        let input: Any = "Hello world!".data(using: String.Encoding.utf8)!
        do {
            let data = try mapper.map(input: input)            
            XCTAssertEqual(String(data: data, encoding: String.Encoding.utf8), "Hello world!")
        }
        catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func test__any_object_coercion_which_fails() {
        let mapper = AnyObjectCoercion<NSNumber>()
        let input: Any = "Hello world!".data(using: String.Encoding.utf8)!
        do {
            let _ = try mapper.map(input: input)
        }
        catch MappingError.unableToPerformMapping { /* test passes */ }
        catch {
            XCTFail("Incorrect error thrown: \(error)")
        }
    }
}

