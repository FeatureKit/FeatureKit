//
//  Storage.swift
//  Features
//
//  Created by Daniel Thorpe on 02/07/2016.
//
//

import Foundation

public typealias VoidBlock = () -> Void

/// Protocol to support storage
public protocol StorageAdaptor {

    /// The type of the item that requires storing
    associatedtype Item

    /// Read the items from Storage
    ///
    /// - parameter [unnamed] completion: a completion block
    /// which receives an array of Item
    func read(_: [Item] -> Void)

    /// Write the item to Storage
    ///
    /// - parameter items: the [Item] to write into storage
    /// - parameter completion: an optional completion block
    func write(items: [Item], completion: VoidBlock?)

    /// Remove all the items from Storage
    ///
    /// - parameter completion: an optional completion block
    func removeAll(completion: VoidBlock?)
}
