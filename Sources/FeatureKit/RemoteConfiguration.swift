//
//  FeatureKit
//
//  Copyright © 2016 FeatureKit. All rights reserved.
//

import Foundation
import Result

public protocol DownloadProtocol {
    associatedtype Output

    @discardableResult func get(request: URLRequest, _: @escaping (Output) -> Void) -> URLSessionTask
}

public typealias RemoteData = (Data?, URLResponse?)

public enum DownloadError: Error {
    case network(Error)
    case mapping(Error)
    case unknown
}

internal class Download<Output>: DownloadProtocol {

    var session: URLSession
    let mapper: AnyMapper<RemoteData, Output>

    init<Base: Mappable>(session: URLSession = URLSession.shared, mapper base: Base) where RemoteData == Base.Input, Output == Base.Output {
        self.session = session
        self.mapper = AnyMapper(base)
    }

    @discardableResult func get(request: URLRequest, _ completion: @escaping (Result<Output, DownloadError>) -> Void) -> URLSessionTask {
        let map = mapper.map
        let task = session.dataTask(with: request) { data, response, error in
            switch (data, response, error) {
            case (_, _, nil):
                do {
                    let result = try map((data, response))
                    completion(Result(value: result))
                }
                catch {
                    completion(Result(error: DownloadError.mapping(error)))
                }

            case let (nil, nil, .some(error)):
                completion(Result(error: DownloadError.network(error)))

            default:
                completion(Result(error: DownloadError.unknown))
            }
        }
        task.resume()
        return task
    }
}
