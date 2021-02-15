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
	
	private let context: NSManagedObjectContext
	
	public init(withContext context: NSManagedObjectContext) {
		self.context = context
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
