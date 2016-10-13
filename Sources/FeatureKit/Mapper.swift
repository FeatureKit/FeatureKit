//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation

public protocol Mappable {
    associatedtype Input
    associatedtype Output

    func map(input: Input) throws -> Output
}

public enum MappingError: Error {
    case unableToPerformMapping(String)
    case requiredOptionalIsNil
}

// MARK: - Type Erasure

fileprivate class AnyMapper_<Input, Output>: Mappable {

    fileprivate func map(input: Input) throws -> Output {
        _abstractMethod()
    }
}

fileprivate final class AnyMapperBox<Base: Mappable>: AnyMapper_<Base.Input, Base.Output> {
    private let base: Base

    fileprivate init(_ base: Base) {
        self.base = base
    }

    fileprivate override func map(input: Base.Input) throws -> Base.Output {
        return try base.map(input: input)
    }
}

public struct AnyMapper<Input, Output>: Mappable {

    private typealias ErasedMapper = AnyMapper_<Input, Output>

    private let box: ErasedMapper!

    public init<Base: Mappable>(_ base: Base) where Input == Base.Input, Output == Base.Output {
        box = AnyMapperBox(base)
    }

    public func map(input: Input) throws -> Output {
        return try box.map(input: input)
    }
}

// MARK: - Composing Mappers

public struct AnyObjectCoercion<Output>: Mappable {

    public func map(input: Any) throws -> Output {
        guard let output = input as? Output else {
            throw MappingError.unableToPerformMapping("Cannot perform coercion from: \(type(of: input)): \(input) to: \(Output.self)")
        }
        return output
    }
}

public struct BlockMapper<Input, Output>: Mappable {

    let transform: (Input) throws -> Output

    public init(transform: @escaping (Input) throws -> Output) {
        self.transform = transform
    }

    public func map(input: Input) throws -> Output {
        return try transform(input)
    }
}

public struct FlatMap<Input, Output>: Mappable {
    let mapper: AnyMapper<Input, Output>

    public init<Base: Mappable>(_ base: Base) where Input == Base.Input, Base.Output == Output {
        mapper = AnyMapper(base)
    }

    public func map(input: Input?) throws -> Output? {
        guard let input = input else { return nil }
        return try mapper.map(input: input)
    }
}

public struct CatchAsOptional<Input, Output>: Mappable {
    let mapper: AnyMapper<Input, Output>

    public init<Base: Mappable>(_ base: Base) where Input == Base.Input, Base.Output == Output {
        mapper = AnyMapper(base)
    }

    public func map(input: Input) throws -> Output? {
        return try? mapper.map(input: input)
    }
}


public struct NotOptional<Input, Output>: Mappable {
    let mapper: AnyMapper<Input, Optional<Output>>

    public init<Base: Mappable>(_ base: Base) where Input == Base.Input, Base.Output == Optional<Output> {
        mapper = AnyMapper(base)
    }

    public func map(input: Input) throws -> Output {
        guard let result = try mapper.map(input: input) else { throw MappingError.requiredOptionalIsNil }
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

    func append<Base: Mappable>(_ base: Base) -> AnyMapper<Input, Base.Output> where Base.Input == Output {
        return AnyMapper<Input, Base.Output>(IntermediateMapper(previous: self, mapper: base))
    }

    func append<NewOutput>(transform: @escaping (Output) throws -> NewOutput) -> AnyMapper<Input, NewOutput> {
        return append(BlockMapper<Output, NewOutput>(transform: transform))
    }
}

internal struct IntermediateMapper<Previous, Next>: Mappable where Previous: Mappable, Next: Mappable, Previous.Output == Next.Input {

    let previous: Previous
    let mapper: Next

    internal func map(input: Previous.Input) throws -> Next.Output {
        return try mapper.map(input: previous.map(input: input))
    }
}
