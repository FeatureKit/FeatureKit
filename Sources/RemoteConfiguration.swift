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
public typealias RemoteResult = Result<RemoteData, NSError>

internal class Download: DownloadProtocol {

    var session: NSURLSession

    init(session: NSURLSession = NSURLSession.sharedSession()) {
        self.session = session
    }

    func get(request: NSURLRequest, _ completion: RemoteResult -> Void) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            let result = error.map { Result(error: $0) } ?? Result(value: (data, response))
            completion(result)
        }
        task.resume()
        return task
    }
}

public class RemoteConfiguration {

    public internal(set) var session: NSURLSession
    public let URL: NSURL

    public init(session: NSURLSession = NSURLSession.sharedSession(), URL: NSURL) {
        self.session = session
        self.URL = URL
    }
}
