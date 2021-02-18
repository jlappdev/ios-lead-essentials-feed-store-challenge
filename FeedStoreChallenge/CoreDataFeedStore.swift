//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by JL Dev on 2/12/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		self.container = try NSPersistentContainer.load(modelName: "FeedStoreChallengeModel", url: storeURL, in: bundle)
		self.context = container.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let context = self.context
		
		context.perform {
			do {
				try ManagedCache.find(in: context).map { context.delete($0) }
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		
		context.perform {
			do {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.feed = ManagedFeedImage.managedImages(from: feed, in: context)
				managedCache.timestamp = timestamp
				
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		
		context.perform {
			do {
				guard let cache = try ManagedCache.find(in: context) else {
					return completion(.empty)
				}
				completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
			} catch {
				completion(.failure(error))
			}
		}
	}
}

private extension NSPersistentContainer {
	enum LoadingError: Swift.Error {
		case failedToLocateModel
		case failedToLoadPersistentStores(Swift.Error)
	}
	
	static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
			throw LoadingError.failedToLocateModel
		}
		
		let description = NSPersistentStoreDescription(url: url)
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		
		var loadError: Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
		
		return container
	}
}

private extension NSManagedObjectModel {
	static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle
			.url(forResource: name, withExtension: "momd")
			.flatMap { NSManagedObjectModel(contentsOf: $0) }
	}
}
