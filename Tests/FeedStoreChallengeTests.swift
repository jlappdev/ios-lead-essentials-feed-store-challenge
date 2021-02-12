//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import CoreData

class CoreDataFeedStore: FeedStore {
	
	private let context: NSManagedObjectContext
	
	init(withContext context: NSManagedObjectContext) {
		self.context = context
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let context = self.context
		
		context.perform {
			do {
				if let managedCache = try ManagedCache.find(in: context) {
					context.delete(managedCache)
					try context.save()
				}
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
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
	
	func retrieve(completion: @escaping RetrievalCompletion) {
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

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	//  ***********************
	//
	//  Follow the TDD process:
	//
	//  1. Uncomment and run one test at a time (run tests with CMD+U).
	//  2. Do the minimum to make the test pass and commit.
	//  3. Refactor if needed and commit again.
	//
	//  Repeat this process until all tests are passing.
	//
	//  ***********************
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()
		
		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()
		
		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() {
		//		let sut = makeSUT()
		//
		//		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() -> FeedStore {
		CoreDataFeedStore(withContext: makeCoreDataStack())
	}
	
	private func makeCoreDataStack(using modelName: String = "FeedStoreChallengeModel") -> NSManagedObjectContext {
		let managedObjectModel = makeManagedObjectModel()
		
		let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
		
		let description = NSPersistentStoreDescription()
		description.url = URL(fileURLWithPath: "/dev/null")
		container.persistentStoreDescriptions = [description]
		
		container.loadPersistentStores { (_, error) in
			if let error = error {
				fatalError("Unable to create Core Data Stack. Failed with \(error)")
			}
		}
		
		return container.newBackgroundContext()
	}
	
	private func makeManagedObjectModel(using modelName: String = "FeedStoreChallengeModel") -> NSManagedObjectModel {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		
		guard let momURL = storeBundle.url(forResource: modelName, withExtension: "momd") else {
			fatalError("Unable to locate Core Data Model file in bundle.")
		}
		guard let mom = NSManagedObjectModel(contentsOf: momURL) else {
			fatalError("Unable to load model file into Managed Object Model.")
		}
		
		return mom
	}
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() {
////		let sut = makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() {
////		let sut = makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
