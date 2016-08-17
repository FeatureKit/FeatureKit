//
//  FeatureKit
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation

public protocol Mappable {
    associatedtype Input
    associatedtype Output

    func map(input: Input) throws -> Output
}

public enum MappingError: ErrorType {
    case unableToPerformMapping(String)
    case requiredOptionalIsNil
}

// MARK: - Type Erasure

private class AnyMapper_<Input, Output>: Mappable {

    private func map(input: Input) throws -> Output {
        _abstractMethod()
    }
}

private final class AnyMapperBox<Base: Mappable>: AnyMapper_<Base.Input, Base.Output> {
    private let base: Base

    private init(_ base: Base) {
        self.base = base
    }

    private override func map(input: Base.Input) throws -> Base.Output {
        return try base.map(input)
    }
}

public struct AnyMapper<Input, Output>: Mappable {

    private typealias ErasedMapper = AnyMapper_<Input, Output>

    private let box: ErasedMapper!

    public init<Base: Mappable where Input == Base.Input, Output == Base.Output>(_ base: Base) {
        box = AnyMapperBox(base)
    }

    public func map(input: Input) throws -> Output {
        return try box.map(input)
    }
}

// MARK: - Composing Mappers

public struct AnyObjectCoercion<Output>: Mappable {

    public func map(input: AnyObject) throws -> Output {
        guard let output = input as? Output else { throw MappingError.unableToPerformMapping("Cannot perform coercion from: \(input.dynamicType): \(input) to: \(Output.self)") }
        return output
    }
}

public struct BlockMapper<Input, Output>: Mappable {

    let transform: (Input) throws -> Output

    public init(transform: (Input) throws -> Output) {
        self.transform = transform
    }

    public func map(input: Input) throws -> Output {
        return try transform(input)
    }
}

public struct FlatMap<Input, Output>: Mappable {
    let mapper: AnyMapper<Input, Output>

    public init<Base: Mappable where Input == Base.Input, Base.Output == Output>(_ base: Base) {
        mapper = AnyMapper(base)
    }

    public func map(input: Input?) throws -> Output? {
        guard let input = input else { return nil }
        return try mapper.map(input)
    }
}

public struct CatchAsOptional<Input, Output>: Mappable {
    let mapper: AnyMapper<Input, Output>

    public init<Base: Mappable where Input == Base.Input, Base.Output == Output>(_ base: Base) {
        mapper = AnyMapper(base)
    }

    public func map(input: Input) throws -> Output? {
        return try? mapper.map(input)
    }
}


public struct NotOptional<Input, Output>: Mappable {
    let mapper: AnyMapper<Input, Optional<Output>>

    public init<Base: Mappable where Input == Base.Input, Base.Output == Optional<Output>>(_ base: Base) {
        mapper = AnyMapper(base)
    }

    public func map(input: Input) throws -> Output {
        guard let result = try mapper.map(input) else { throw MappingError.requiredOptionalIsNil }
        return result
    }
}

public struct Many<Mapper: Mappable>: Mappable {
    let mapper: Mapper

    public init(_ mapper: Mapper) {
        self.mapper = mapper
    }

    public func map(input: [Mapper.Input]) throws -> [Mapper.Output] {
        return try input.map(mapper.map)
    }
}

// MARK: - Appending Mappers

public extension Mappable {

    func append<Base: Mappable where Base.Input == Output>(base: Base) -> AnyMapper<Input, Base.Output> {
        return AnyMapper<Input, Base.Output>(IntermediateMapper(previous: self, mapper: base))
    }

    func append<NewOutput>(transform: (Output) throws -> NewOutput) -> AnyMapper<Input, NewOutput> {
        return append(BlockMapper<Output, NewOutput>(transform: transform))
    }
}

internal struct IntermediateMapper<Previous, Next where Previous: Mappable, Next: Mappable, Previous.Output == Next.Input>: Mappable {

    let previous: Previous
    let mapper: Next

    internal func map(input: Previous.Input) throws -> Next.Output {
        return try mapper.map(previous.map(input))
    }
}
