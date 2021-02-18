//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreIntegrationTests: XCTestCase {
	
	//  ***********************
	//
	//  Uncomment and implement the following tests if your
	//  implementation persists data to disk (e.g., CoreData/Realm)
	//
	//  ***********************
	
	override func setUp() {
		super.setUp()
		
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		
		undoStoreSideEffects()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		expect(sut, toRetrieve: .empty)
	}
	
	func test_retrieve_deliversFeedInsertedOnAnotherInstance() {
		let storeToInsert = makeSUT()
		let storeToLoad = makeSUT()
		let feed = uniqueImageFeed()
		let timestamp = Date()
		
		insert((feed, timestamp), to: storeToInsert)
		
		expect(storeToLoad, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_insert_overridesFeedInsertedOnAnotherInstance() {
		let storeToInsert = makeSUT()
		let storeToOverride = makeSUT()
		let storeToLoad = makeSUT()
		
		insert((uniqueImageFeed(), Date()), to: storeToInsert)
		
		let latestFeed = uniqueImageFeed()
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: storeToOverride)
		
		expect(storeToLoad, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	func test_delete_deletesFeedInsertedOnAnotherInstance() {
		let storeToInsert = makeSUT()
		let storeToDelete = makeSUT()
		let storeToLoad = makeSUT()
		
		insert((uniqueImageFeed(), Date()), to: storeToInsert)
		
		deleteCache(from: storeToDelete)
		
		expect(storeToLoad, toRetrieve: .empty)
	}
	
	// - MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CoreDataFeedStore(usingContainer: makeCoreDataStack(at: testSpecificStoreURL()))
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return sut
	}
	
	private func makeCoreDataStack(at url: URL, using modelName: String = "FeedStoreChallengeModel") -> NSPersistentContainer {
		let managedObjectModel = makeManagedObjectModel()
		let description = NSPersistentStoreDescription(url: url)
		let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
		
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores { (_, error) in
			if let error = error {
				fatalError("Unable to create Core Data Stack. Failed with \(error)")
			}
		}
		
		return container
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
	
	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}
