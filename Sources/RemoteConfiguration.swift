//
//  FeatureKit
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation
import Result

public protocol DownloadProtocol {
    associatedtype Output

    func get(request: NSURLRequest, _: (Output) -> Void) -> NSURLSessionTask
}

public typealias RemoteData = (NSData?, NSURLResponse?)

public enum DownloadError: ErrorType {
    case network(NSError)
    case mapping(ErrorType)
    case unknown
}

internal class Download<Output>: DownloadProtocol {

    var session: NSURLSession
    let mapper: AnyMapper<RemoteData, Output>

    init<Base: Mappable where RemoteData == Base.Input, Output == Base.Output>(session: NSURLSession = NSURLSession.sharedSession(), mapper base: Base) {
        self.session = session
        self.mapper = AnyMapper(base)
    }

    func get(request: NSURLRequest, _ completion: Result<Output, DownloadError> -> Void) -> NSURLSessionTask {
        let map = mapper.map
        let task = session.dataTaskWithRequest(request) { data, response, error in
            switch (data, response, error) {
            case (_, _, nil):
                do {
                    let result = try map((data, response))
                    completion(Result(value: result))
                }
                catch {
                    completion(Result(error: DownloadError.mapping(error)))
                }

            case let (nil, nil, .Some(error)):
                completion(Result(error: DownloadError.network(error)))

            default:
                completion(Result(error: DownloadError.unknown))
            }
        }
        task.resume()
        return task
    }
}
