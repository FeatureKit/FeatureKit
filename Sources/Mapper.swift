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

    func map(input: Input) -> Output
}


private class AnyMapper_<Input, Output>: Mappable {

    private func map(input: Input) -> Output {
        _abstractMethod()
    }
}

private final class AnyMapperBox<Base: Mappable>: AnyMapper_<Base.Input, Base.Output> {
    private let base: Base

    private init(_ base: Base) {
        self.base = base
    }

    private override func map(input: Base.Input) -> Base.Output {
        return base.map(input)
    }
}

public struct AnyMapper<Input, Output>: Mappable {

    private typealias ErasedMapper = AnyMapper_<Input, Output>

    private let box: ErasedMapper!

    public init<Base: Mappable where Input == Base.Input, Output == Base.Output>(_ base: Base) {
        box = AnyMapperBox(base)
    }

    public func map(input: Input) -> Output {
        return box.map(input)
    }

    public func append<Base: Mappable where Base.Input == Output>(base: Base) -> AnyMapper<Input, Base.Output> {
        return AnyMapper<Input, Base.Output>(IntermediateMapper(previous: self, mapper: base))
    }
}

internal struct IntermediateMapper<Previous, Next where Previous: Mappable, Next: Mappable, Previous.Output == Next.Input>: Mappable {

    let previous: Previous
    let mapper: Next

    internal func map(input: Previous.Input) -> Next.Output {
        return mapper.map(previous.map(input))
    }
}
