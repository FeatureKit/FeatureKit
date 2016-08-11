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
    case unableToPerformMapping
}

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

    public func append<Base: Mappable where Base.Input == Output>(base: Base) -> AnyMapper<Input, Base.Output> {
        return AnyMapper<Input, Base.Output>(IntermediateMapper(previous: self, mapper: base))
    }
}

internal struct IntermediateMapper<Previous, Next where Previous: Mappable, Next: Mappable, Previous.Output == Next.Input>: Mappable {

    let previous: Previous
    let mapper: Next

    internal func map(input: Previous.Input) throws -> Next.Output {
        return try mapper.map(previous.map(input))
    }
}

public struct AnyObjectCoercion<Output>: Mappable {

    public func map(input: AnyObject) throws -> Output {
        guard let output = input as? Output else { throw MappingError.unableToPerformMapping }
        return output
    }
}
