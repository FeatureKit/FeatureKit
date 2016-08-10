//
//  FeatureKit
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation

public protocol MapperProtocol {
    associatedtype Input
    associatedtype Output

    func map(input: Input) -> Output
}


private class AnyMapper_<Input, Output>: MapperProtocol {

    private func map(input: Input) -> Output {
        _abstractMethod()
    }
}

private final class AnyMapperBox<Base: MapperProtocol>: AnyMapper_<Base.Input, Base.Output> {
    private let base: Base

    private init(_ base: Base) {
        self.base = base
    }

    private override func map(input: Base.Input) -> Base.Output {
        return base.map(input)
    }
}

public struct AnyMapper<Input, Output>: MapperProtocol {

    private typealias ErasedMapper = AnyMapper_<Input, Output>

    private let box: ErasedMapper!

    public init<Base: MapperProtocol where Input == Base.Input, Output == Base.Output>(_ base: Base) {
        box = AnyMapperBox(base)
    }

    public func map(input: Input) -> Output {
        return box.map(input)
    }
}
