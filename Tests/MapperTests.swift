//
//  FeatureKit
//
//  Created by Daniel Thorpe on 11/08/2016.
//
//

import Foundation
import XCTest
@testable import Features

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
        XCTAssertEqual(try! mapper.map("Hello"), "Hello!")
    }

    func test__append_mappers() {
        let mapper = AnyMapper(AppendExclamation())
            .append(AppendQuestionMark())
            .append(CharacterCount())
        XCTAssertEqual(try! mapper.map("Hello"), 7)
    }

    func test__any_object_coercion() {
        let mapper = AnyObjectCoercion<NSData>()
        let input: AnyObject = "Hello world!".dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let data = try mapper.map(input)
            XCTAssertTrue(data.isKindOfClass(NSData))
            XCTAssertEqual(String(data: data, encoding: NSUTF8StringEncoding), "Hello world!")
        }
        catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func test__any_object_coercion_which_fails() {
        let mapper = AnyObjectCoercion<NSNumber>()
        let input: AnyObject = "Hello world!".dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let _ = try mapper.map(input)
        }
        catch MappingError.unableToPerformMapping { /* test passes */ }
        catch {
            XCTFail("Incorrect error thrown: \(error)")
        }
    }
}

