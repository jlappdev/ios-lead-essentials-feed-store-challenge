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
		perform { context in
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
		perform { context in
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
		perform { context in
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
	
	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		
		context.perform {
			action(context)
		}
	}
}
