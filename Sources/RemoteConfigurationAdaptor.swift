//
//  FileAdaptor.swift
//  Features
//
//  Created by Daniel Thorpe on 03/07/2016.
//
//

import Foundation
import Result

public protocol RemoteDataMapper {

    associatedtype Item

    func map(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<[Item], NSError>
}

internal class RemoteFileProviderClient<Mapper: RemoteDataMapper> {

    let session: NSURLSession
    let mapper: Mapper

    init(session: NSURLSession = NSURLSession.sharedSession(), mapper: Mapper) {
        self.session = session
        self.mapper = mapper
    }

    func get(request: NSURLRequest, completion: Result<[Mapper.Item], NSError> -> Void) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(request) { [unowned self] data, response, error in
            let result = error.map { Result(error: $0) } ?? Result(value: (data, response))
            completion(self.mapper.map(result))
        }
        task.resume()
        return task
    }
}

public protocol RemoteConfigurationProvider {

    static func session() -> NSURLSession

    var URL: NSURL { get }

    var request: NSURLRequest { get }
}

public extension RemoteConfigurationProvider {

    static func session() -> NSURLSession {
        return NSURLSession.sharedSession()
    }

    var request: NSURLRequest {
        return NSURLRequest(URL: URL)
    }
}


public class RemoteConfigurationAdaptor<Mapper: RemoteDataMapper>: StorageAdaptor, RemoteConfigurationProvider {

    public let URL: NSURL
    let mapper: Mapper
    let storage: AnyStorage<Mapper.Item>

    public init(URL: NSURL, mapper: Mapper, storage: AnyStorage<Mapper.Item>) {
        self.URL = URL
        self.mapper = mapper
        self.storage = storage
    }

    public convenience init<Base: StorageAdaptor where Mapper.Item == Base.Item>(URL: NSURL, mapper: Mapper, storage: Base) {
        self.init(URL: URL, mapper: mapper, storage: storage)
    }

    public func read(completion: [Mapper.Item] -> Void) {
        let client = RemoteFileProviderClient(session: self.dynamicType.session(), mapper: mapper)
        client.get(request) { [unowned self] result in
            if let items = try? result.dematerialize() {
                self.write(items) { completion(items) }
            }
        }
    }

    public func write(items: [Mapper.Item], completion: VoidBlock? = nil) {
        storage.write(items, completion: completion)
    }

    public func removeAll(completion: VoidBlock? = nil) {
        storage.removeAll(completion)
    }
}
